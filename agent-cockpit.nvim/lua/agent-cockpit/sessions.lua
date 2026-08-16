-- Per-agent session-id capture, used by crash recovery to resume the RIGHT
-- session when several workers share a cwd (cwd-scoped resume like
-- `kimi --continue` collides in that case).
--
-- Capture is content-matched: when several kimi workers boot at once in the
-- same cwd, "first new session in the index" races — every poller would claim
-- the same session. Instead each capture carries a `match` string (a unique
-- substring of the worker's initial prompt, e.g. its status-file path) and
-- claims only the session whose wire log contains it.
local M = {}

local function default_index()
  return vim.fn.expand('~/.kimi-code/session_index.jsonl')
end

local function norm(p) return (p:gsub('\\', '/'):lower()) end

--- Map of kimi session id -> sessionDir for records whose workDir equals cwd
--- (slash/case-normalized).
function M.kimi_sessions(cwd, index_path)
  local want = norm(cwd)
  local out = {}
  local f = io.open(index_path or default_index(), 'r')
  if not f then return out end
  for line in f:lines() do
    local ok, rec = pcall(vim.json.decode, line)
    if ok and type(rec) == 'table' and rec.workDir and rec.sessionId
      and norm(rec.workDir) == want then
      out[rec.sessionId] = rec.sessionDir or true
    end
  end
  f:close()
  return out
end

--- Set of kimi session ids for cwd (kept for older callers/tests).
function M.kimi_session_ids(cwd, index_path)
  local ids = {}
  for id in pairs(M.kimi_sessions(cwd, index_path)) do ids[id] = true end
  return ids
end

-- Does the session's wire log contain `match`? Reads at most 256KB — the
-- initial prompt is an early record. Missing/unreadable files answer false.
local function session_mentions(dir, match)
  if type(dir) ~= 'string' then return false end
  local f = io.open(dir .. '/agents/main/wire.jsonl', 'r')
  if not f then return false end
  local body = f:read(262144) or ''
  f:close()
  return body:find(match, 1, true) ~= nil
end

--- Poll the index until a session appears that is not in `before` (and not
--- already claimed by a concurrent capture), then call cb(id).
--- opts:
---   match      — claim only a session whose wire log contains this string;
---                without it, the first unclaimed new session wins
---   claimed    — shared set of session ids claimed this boot (concurrency)
---   index_path — test override for the index file
---   attempts   — poll count, one per second (default 45)
function M.capture_kimi(cwd, before, cb, opts)
  opts = opts or {}
  local attempts = opts.attempts or 45
  local claimed = opts.claimed or {}
  local function poll(n)
    local current = M.kimi_sessions(cwd, opts.index_path)
    for id, dir in pairs(current) do
      if not before[id] and not claimed[id]
        and (not opts.match or session_mentions(dir, opts.match)) then
        claimed[id] = true
        return cb(id)
      end
    end
    if n > 1 then vim.defer_fn(function() poll(n - 1) end, 1000) end
  end
  poll(attempts)
end

return M
