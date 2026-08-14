local agent = require('agent-cockpit')

local M = {}

local function ok(data) return vim.json.encode({ ok = true, data = data }) end
local function fail(msg) return vim.json.encode({ ok = false, error = msg }) end

local function parse(args)
  -- returns positional array, opts table; repeated --op k=v -> opts.op_overrides
  local pos, opts = {}, {}
  local i = 1
  while i <= #args do
    local a = args[i]
    local flag = a:match('^%-%-(%S+)$')
    if flag and args[i + 1] then
      local v = args[i + 1]
      if flag == 'op' then
        local k, val = v:match('^(.-)=(.*)$')
        opts.op_overrides = opts.op_overrides or {}
        if k then opts.op_overrides[k] = val end
      else
        opts[flag] = v
      end
      i = i + 2
    else
      pos[#pos + 1] = a
      i = i + 1
    end
  end
  return pos, opts
end

M.commands = {
  spawn = function(pos, o)
    local res, e = agent.spawn(pos[1], {
      cmd = o.cmd, cwd = o.cwd, task_file = o.task, role = o.role,
      prompt = o.prompt, op_overrides = o.op_overrides,
    })
    if not res then return fail(e) end
    return ok(res)
  end,
  ['team-apply'] = function()
    local res, e = agent.team_apply()
    return res and ok(res) or fail(e)
  end,
  ['team-dump'] = function(pos)
    local res, e = agent.team_dump(pos[1])
    return res and ok(res) or fail(e)
  end,
  ['team-raise'] = function(pos)
    local res, e = agent.team_raise(pos[1])
    return res and ok(res) or fail(e)
  end,
  focus = function(pos) return M._simple(agent.focus, pos[1]) end,
  hide = function(pos) return M._simple(agent.hide, pos[1]) end,
  kill = function(pos) return M._simple(agent.kill, pos[1]) end,
  send = function(pos) return M._simple(agent.send, pos[1], pos[2] or '') end,
  prompt = function(pos) return M._simple(agent.prompt, pos[1], pos[2] or '') end,
  op = function(pos) return M._simple(agent.op, pos[1], pos[2]) end,
  ops = function(pos)
    local res, e = agent.ops(pos[1])
    return res and ok(res) or fail(e)
  end,
  ['send-keys'] = function(pos) return M._simple(agent.send_keys, pos[1], pos[2]) end,
  edit = function(pos) return M._simple(agent.edit, pos[1]) end,
  diff = function(pos) return M._simple(agent.diff, pos[1]) end,
  list = function() return ok(agent.list()) end,
  layout = function(pos)
    if pos[1] then
      local pok, e = pcall(agent.layout, pos[1])
      if not pok then return fail(tostring(e)) end
    end
    return ok(agent.layout())
  end,
  dashboard = function() return M._simple(agent.dashboard) end,
  status = function(pos)
    local res, e = agent.status(pos[1])
    return res and ok(res) or fail(e)
  end,
}

function M._simple(fn, ...)
  local res, e = fn(...)
  return res and ok(res) or fail(e)
end

function M.run(payload)
  local args = {}
  for line in payload:gmatch('[^\n]+') do
    args[#args + 1] = vim.base64.decode(line)
  end
  local cmd = table.remove(args, 1)
  local handler = cmd and M.commands[cmd]
  if not handler then
    return fail('unknown command: ' .. tostring(cmd))
  end
  local pok, result = pcall(handler, parse(args))
  if not pok then return fail('internal error: ' .. tostring(result)) end
  return result
end

return M
