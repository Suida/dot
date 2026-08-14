-- Team model: roster (.agent/roster.md) + per-role briefs (.agent/roles/).
-- The roster is a markdown table written by the main agent and approved by
-- the operator; team.apply spawns every roster member not already running.
local M = {}

function M.roster_path(root) return root .. '/.agent/roster.md' end
function M.brief_path(root, role) return root .. '/.agent/roles/' .. role .. '.md' end
function M.has_roster(root) return vim.fn.filereadable(M.roster_path(root)) == 1 end

function M.parse_roster(text)
  local out = {}
  for line in text:gmatch('[^\n]+') do
    if line:match('^%s*|') then
      local cells = {}
      for cell in line:gmatch('|([^|]*)') do
        cells[#cells + 1] = vim.trim(cell)
      end
      local role = cells[1]
      if role and role ~= '' and role:lower() ~= 'role' and not role:match('^%-+$') then
        out[#out + 1] = {
          role = role,
          cli = (cells[2] ~= '' and cells[2]) or 'kimi',
          responsibilities = cells[3] or '',
        }
      end
    end
  end
  return out
end

function M.read_roster(root)
  local f = io.open(M.roster_path(root), 'r')
  if not f then return nil end
  local text = f:read('a')
  f:close()
  return M.parse_roster(text)
end

local function scaffold_brief(role, responsibilities)
  return table.concat({
    '# Role: ' .. role,
    '',
    '- Responsibilities: ' .. (responsibilities ~= '' and responsibilities or '(fill in)'),
    '- Scope: (files/dirs in scope; what NOT to touch)',
    '- Conventions: keep .agent/status/' .. role .. '.md current'
      .. ' (first line `state: working|blocked|done`, then a one-line summary)',
    '- Current assignment: (set by the main agent)',
    '',
  }, '\n')
end

--- Spawn every roster member that is not already running.
--- Returns the list of spawned roles, or nil + error.
function M.apply(root)
  local roster = M.read_roster(root)
  if not roster or #roster == 0 then
    return nil, 'no roster at ' .. M.roster_path(root)
  end
  local agent = require('agent-cockpit')
  local reg = require('agent-cockpit.registry')
  vim.fn.mkdir(root .. '/.agent/roles', 'p')
  local spawned = {}
  for _, m in ipairs(roster) do
    if m.role ~= 'main' and not reg.get(m.role) then
      local brief = M.brief_path(root, m.role)
      if vim.fn.filereadable(brief) == 0 then
        local f = io.open(brief, 'w')
        f:write(scaffold_brief(m.role, m.responsibilities))
        f:close()
      end
      local res, serr = agent.spawn(m.role, {
        cmd = m.cli, role = m.role, task_file = brief,
      })
      if not res then
        return nil, ('spawn %s failed: %s'):format(m.role, tostring(serr))
      end
      spawned[#spawned + 1] = m.role
    end
  end
  return spawned
end

-- Templates ---------------------------------------------------------------

function M.template_dir()
  return vim.fn.stdpath('data') .. '/agent-cockpit/templates'
end

local function cp(src, dst)
  local f = io.open(src, 'r')
  if not f then return false end
  local body = f:read('a')
  f:close()
  local g = io.open(dst, 'w')
  if not g then return false end
  g:write(body)
  g:close()
  return true
end

function M.dump(root, name)
  if not name or name == '' then return nil, 'template name required' end
  if not M.has_roster(root) then return nil, 'no roster to dump' end
  local dest = M.template_dir() .. '/' .. name
  vim.fn.mkdir(dest .. '/roles', 'p')
  cp(M.roster_path(root), dest .. '/roster.md')
  for _, m in ipairs(M.read_roster(root) or {}) do
    cp(M.brief_path(root, m.role), dest .. '/roles/' .. m.role .. '.md')
  end
  return dest
end

function M.raise(root, name)
  local src = M.template_dir() .. '/' .. name
  if vim.fn.filereadable(src .. '/roster.md') == 0 then
    return nil, 'no such template: ' .. tostring(name)
  end
  vim.fn.mkdir(root .. '/.agent/roles', 'p')
  cp(src .. '/roster.md', M.roster_path(root))
  local fs = vim.uv.fs_scandir(src .. '/roles')
  if fs then
    while true do
      local fname = vim.uv.fs_scandir_next(fs)
      if not fname then break end
      cp(src .. '/roles/' .. fname, root .. '/.agent/roles/' .. fname)
    end
  end
  return M.apply(root)
end

return M
