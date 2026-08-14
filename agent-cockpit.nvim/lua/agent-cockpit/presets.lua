local M = { user = {} }

M.shipped = {
  default = { interrupt = '<C-c>', submit = '<CR>', newline = '<C-j>' },
  kimi = { resume = 'kimi --continue', resume_suffix = '--session {session}' },
  codex = { newline = '<A-CR>', resume = 'codex resume --last' },
}

local function merge(dst, src)
  if type(src) ~= 'table' then return end
  for k, v in pairs(src) do dst[k] = v end
end

local function load_project(root)
  local path = root .. '/.agent/presets.lua'
  if vim.fn.filereadable(path) ~= 1 then return {} end
  local chunk, err = loadfile(path)
  if not chunk then
    vim.notify('agent-cockpit: .agent/presets.lua: ' .. err, vim.log.levels.WARN)
    return {}
  end
  local ok, tbl = pcall(chunk)
  if not ok or type(tbl) ~= 'table' then
    vim.notify('agent-cockpit: .agent/presets.lua must return a table', vim.log.levels.WARN)
    return {}
  end
  return tbl
end

function M.resolve(agent, root, spawn_overrides)
  local out = {}
  merge(out, M.shipped.default)
  merge(out, M.shipped[agent])
  merge(out, M.user.default)
  merge(out, M.user[agent])
  local proj = load_project(root)
  merge(out, proj.default)
  merge(out, proj[agent])
  merge(out, spawn_overrides)
  return out
end

function M.ops(preset)
  local names = {}
  for k in pairs(preset) do
    if k ~= 'resume' and k ~= 'resume_suffix' then names[#names + 1] = k end
  end
  table.sort(names)
  return names
end

return M
