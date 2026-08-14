-- Per-agent session-id capture, used by crash recovery to resume the RIGHT
-- session when several workers share a cwd (cwd-scoped resume like
-- `kimi --continue` collides in that case).
local M = {}

local function default_index()
  return vim.fn.expand('~/.kimi-code/session_index.jsonl')
end

--- Set of kimi session ids whose workDir equals cwd (slash/case-normalized).
function M.kimi_session_ids(cwd, index_path)
  local function norm(p) return (p:gsub('\\', '/'):lower()) end
  local want = norm(cwd)
  local ids = {}
  local f = io.open(index_path or default_index(), 'r')
  if not f then return ids end
  for line in f:lines() do
    local ok, rec = pcall(vim.json.decode, line)
    if ok and type(rec) == 'table' and rec.workDir and rec.sessionId
      and norm(rec.workDir) == want then
      ids[rec.sessionId] = true
    end
  end
  f:close()
  return ids
end

--- Poll the index until a session id appears that is not in `before`
--- (i.e. created by the worker spawned just after the snapshot), then call
--- cb(id). Gives up after `attempts` tries, one per second.
function M.capture_kimi(cwd, before, cb, index_path, attempts)
  attempts = attempts or 20
  local function poll(n)
    local current = M.kimi_session_ids(cwd, index_path)
    for id in pairs(current) do
      if not before[id] then return cb(id) end
    end
    if n > 1 then vim.defer_fn(function() poll(n - 1) end, 1000) end
  end
  poll(attempts)
end

return M
