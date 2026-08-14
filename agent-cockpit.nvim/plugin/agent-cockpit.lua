-- :Agent* user commands — the operator's interface to the cockpit.
if vim.g.loaded_agent_cockpit then return end
vim.g.loaded_agent_cockpit = true

local function agent() return require('agent-cockpit') end

local function complete_workers()
  local out = {}
  for _, e in ipairs(require('agent-cockpit.registry').list()) do
    out[#out + 1] = e.id
  end
  return out
end

vim.api.nvim_create_user_command('AgentSpawn', function(a)
  local opts = {}
  local id
  local i = 1
  while i <= #a.fargs do
    local k = a.fargs[i]
    if k:match('^%-%-') then
      opts[k:sub(3)] = a.fargs[i + 1]
      i = i + 2
    else
      id = k
      i = i + 1
    end
  end
  local res, err = agent().spawn(id, { cmd = opts.cmd, role = opts.role,
    task_file = opts.task })
  if not res then vim.notify('AgentSpawn: ' .. tostring(err), vim.log.levels.ERROR) end
end, { nargs = '+', desc = 'Spawn an agent worker' })

local function simple(name, fn, opts)
  vim.api.nvim_create_user_command(name, function(a)
    local res, err = fn(a.args ~= '' and a.args or nil)
    if not res and err then
      vim.notify(name .. ': ' .. tostring(err), vim.log.levels.ERROR)
    end
  end, opts or {})
end

simple('AgentKill', function(id) return agent().kill(id) end,
  { nargs = 1, complete = complete_workers })
simple('AgentFocus', function(id) return agent().focus(id) end,
  { nargs = 1, complete = complete_workers, desc = 'Focus member (Mode B slot)' })
simple('AgentJump', function(id) return agent().jump(id) end,
  { nargs = 1, complete = complete_workers })
simple('AgentDashboard', function() return agent().dashboard() end, {})
simple('AgentLayout', function(mode)
  return agent().layout(mode) end,
  { nargs = '?', complete = function() return { 'A', 'B' } end })
simple('AgentDiff', function(id) return agent().diff(id) end,
  { nargs = 1, complete = complete_workers })
simple('AgentTeamApply', function() return agent().team_apply() end, {})
simple('AgentTeamDump', function(name) return agent().team_dump(name) end, { nargs = 1 })
simple('AgentTeamRaise', function(name) return agent().team_raise(name) end, { nargs = 1 })
simple('AgentInstall', function(dir) return agent().install(dir) end,
  { nargs = '?', desc = 'Install agent-ctl shim into a PATH dir' })
