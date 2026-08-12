local reg = require('agent.registry')
local presets = require('agent.presets')
local layout = require('agent.layout')

local M = { _foreground = nil }

local function root() return M._root or vim.fn.getcwd() end

local function err(msg, extra)
  return nil, msg, extra
end

function M.setup(opts)
  opts = opts or {}
  M._config = { auto_recover = opts.auto_recover or 'ask' }
  presets.user = opts.presets or {}
  M._root = vim.fn.getcwd()

  local map = vim.keymap.set
  map('n', '<leader>a', function()
    local ok, picker = pcall(require, 'agent.picker')
    if ok then picker.open() else vim.notify('agent picker unavailable', vim.log.levels.WARN) end
  end, { desc = 'Agent workers' })
  map('n', '<leader>E', function()
    local ok, snacks = pcall(require, 'snacks')
    if ok then snacks.picker.explorer() end
  end, { desc = 'Explorer' })
  for i = 1, 9 do
    map({ 'n', 'i', 't' }, '<A-' .. i .. '>', function()
      local e = reg.by_index(i)
      if e then M.focus(e.id) end
    end, { desc = 'Focus worker ' .. i })
  end
  map({ 'n', 'i', 't' }, '<M-Backspace>', function()
    if M._foreground and reg.get(M._foreground)
      and reg.visible(reg.get(M._foreground)) then
      M.hide(M._foreground)
    elseif M._foreground and reg.get(M._foreground) then
      M.focus(M._foreground)
    end
  end, { desc = 'Toggle last worker pane' })

  M._maybe_recover() -- stub until Task 9
end

function M._maybe_recover() end -- replaced in Task 9

local function default_prompt(id, task_file)
  return ('Read %s and follow it. Keep the status file .agent/status/%s.md current.')
    :format(task_file, id)
end

function M.spawn(id, o)
  o = o or {}
  if reg.get(id) then return err('duplicate worker id: ' .. id .. ' (kill it first)') end
  local cmd = o.cmd or 'kimi'
  -- Quote-aware: allow a double-quoted executable path (e.g. "C:\Program Files\...").
  local head = cmd:match('^"(.-)"') or cmd:match('^%S+')
  if vim.fn.executable(head) ~= 1 then
    return err('command not found on PATH: ' .. tostring(head))
  end
  local prompt = o.prompt or (o.task_file and default_prompt(id, o.task_file))
  local cmdline = prompt and (cmd .. ' ' .. vim.fn.shellescape(prompt)) or cmd

  local buf = vim.api.nvim_create_buf(false, true)
  local job
  vim.api.nvim_buf_call(buf, function()
    job = vim.fn.termopen(cmdline, { cwd = o.cwd or root() })
  end)
  if job <= 0 then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    return err('termopen failed for: ' .. cmdline)
  end
  -- Name AFTER termopen: termopen renames the buffer to term://...
  vim.api.nvim_buf_set_name(buf, 'agent://worker/' .. id)
  reg.add(id, {
    id = id, buf = buf, job = job,
    agent = head, cmd = cmd, cwd = o.cwd or root(),
    task_file = o.task_file, op_overrides = o.op_overrides or {},
  })
  return { buf = buf, job = job }
end

local function live_entry(id)
  local e = reg.get(id)
  if not e then return nil, 'unknown worker: ' .. tostring(id) end
  return e
end

function M.focus(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  layout.show(e.buf)
  M._foreground = id
  return true
end

function M.hide(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  layout.hide(e.buf)
  return true
end

function M.kill(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  pcall(vim.fn.jobstop, e.job)
  if vim.api.nvim_buf_is_valid(e.buf) then
    pcall(vim.api.nvim_buf_delete, e.buf, { force = true })
  end
  reg.remove(id)
  if M._foreground == id then M._foreground = nil end
  return true
end

function M.edit(path)
  layout.open_main(path)
  return true
end

local function read_status(id)
  local path = root() .. '/.agent/status/' .. id .. '.md'
  local f = io.open(path, 'r')
  if not f then return 'unknown', '' end
  local first = f:read('l') or ''
  local rest = f:read('a') or ''
  f:close()
  local state = first:match('^state:%s*(%S+)')
  if not state then return 'unknown', (first .. '\n' .. rest) end
  return state, vim.trim(rest)
end

local function live_job(id)
  local e, eerr = live_entry(id)
  if not e then return nil, eerr end
  if not reg.alive(e) then
    local state = read_status(id)
    return nil, ('worker %s job is dead (last state: %s)'):format(id, state)
  end
  return e
end

function M.send(id, text)
  local e, eerr = live_job(id)
  if not e then return err(eerr) end
  vim.fn.chansend(e.job, text)
  return true
end

local function resolve_preset(e)
  return presets.resolve(e.agent, root(), e.op_overrides)
end

function M.op(id, name)
  local e, eerr = live_job(id)
  if not e then return err(eerr) end
  local preset = resolve_preset(e)
  local key = preset[name]
  if not key then
    return err(('unknown op %q for %s; available: %s')
      :format(tostring(name), e.agent, table.concat(presets.ops(preset), ', ')))
  end
  vim.fn.chansend(e.job, vim.api.nvim_replace_termcodes(key, true, true, true))
  return true
end

function M.prompt(id, text)
  local ok1, e1 = M.send(id, text)
  if not ok1 then return err(e1) end
  return M.op(id, 'submit')
end

function M.send_keys(id, keys)
  local e, eerr = live_job(id)
  if not e then return err(eerr) end
  vim.fn.chansend(e.job, vim.api.nvim_replace_termcodes(keys, true, true, true))
  return true
end

function M.ops(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  return presets.ops(resolve_preset(e))
end

local function describe(e)
  local state, summary = read_status(e.id)
  return {
    id = e.id, cmd = e.cmd, cwd = e.cwd, task_file = e.task_file,
    alive = reg.alive(e), visible = reg.visible(e),
    state = state, summary = summary,
  }
end

function M.list()
  local out = {}
  for _, e in ipairs(reg.list()) do out[#out + 1] = describe(e) end
  return out
end

function M.status(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  return describe(e)
end

return M
