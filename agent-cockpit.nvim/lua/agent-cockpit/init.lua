local reg = require('agent-cockpit.registry')
local presets = require('agent-cockpit.presets')
local zones = require('agent-cockpit.zones')

local M = { _foreground = nil }

local function root() return M._root or vim.fn.getcwd() end

local function err(msg, extra)
  return nil, msg, extra
end

function M.setup(opts)
  opts = opts or {}
  M._config = {
    auto_recover = opts.auto_recover or 'ask',
    -- Agent CLI to run as the cockpit's main agent on launch; false disables.
    -- The orchestrator needs autonomy flags: without them it stalls on
    -- per-command approval prompts while driving agent-ctl.
    main_agent = opts.main_agent == nil and 'kimi --yolo' or opts.main_agent,
  }
  presets.user = opts.presets or {}
  M._root = vim.fn.getcwd()
  require('agent-cockpit.socket').ensure(M._root)

  local map = vim.keymap.set
  map('n', '<leader>a', function()
    local ok, picker = pcall(require, 'agent-cockpit.picker')
    if ok then picker.open() else vim.notify('agent picker unavailable', vim.log.levels.WARN) end
  end, { desc = 'Agent workers' })
  map('n', '<leader>E', function()
    local ok, snacks = pcall(require, 'snacks')
    if ok then snacks.picker.explorer() end
  end, { desc = 'Explorer' })
  map('n', '<leader>r', function()
    require('agent-cockpit.zones').toggle_review()
  end, { desc = 'Toggle review area' })
  map('n', '<leader>d', function() M.dashboard() end, { desc = 'Agent dashboard' })
  map('n', '<leader>m', function()
    require('agent-cockpit.zones').toggle_mode()
    require('agent-cockpit.persist').save()
  end, { desc = 'Toggle agent layout mode A/B' })
  for i = 1, 9 do
    map({ 'n', 'i', 't' }, '<A-' .. i .. '>', function()
      local e = reg.by_index(i)
      if e then M.jump(e.id) end
    end, { desc = 'Focus worker ' .. i })
  end
  map({ 'n', 'i', 't' }, '<M-Backspace>', function()
    if M._foreground and reg.get(M._foreground)
      and reg.visible(reg.get(M._foreground)) then
      M.hide(M._foreground)
    elseif M._foreground and reg.get(M._foreground) then
      M.jump(M._foreground)
    end
  end, { desc = 'Toggle last worker pane' })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function() require('agent-cockpit.persist').mark_clean_exit() end,
  })

  -- Deliberately wiped worker buffers leave the registry, so crash recovery
  -- never respawns them and focus/status report a clean 'unknown worker'.
  vim.api.nvim_create_autocmd('BufWipeout', {
    callback = function(args)
      local id = args.match:match('agent://worker/(.+)$')
      if not id or not reg.get(id) then return end
      reg.remove(id)
      if M._foreground == id then M._foreground = nil end
      require('agent-cockpit.persist').save()
    end,
  })

  if not M._maybe_recover() then M._open_main_agent() end

  require('agent-cockpit.dashboard').watch(M._root)
end

--- Spawn the main agent (worker id 'main') and foreground it, unless the
--- registry already has workers (e.g. crash recovery ran first).
function M._open_main_agent()
  local cmd = M._config and M._config.main_agent
  if not cmd then return end
  if #reg.list() > 0 then return end
  vim.schedule(function()
    if #reg.list() > 0 then return end -- recovery may have beaten the schedule
    local prime = table.concat({
      'You are the main agent of an agent-cockpit Neovim instance; you are',
      'running inside a terminal buffer of the instance you orchestrate.',
      'First read the skill file ~/.agents/skills/nvim-agent-orchestration/SKILL.md',
      'and follow it from now on. The `agent-ctl` command is on your PATH and',
      'controls this Neovim (team rosters, spawn/focus/steer members, layout,',
      'dashboard); NVIM_AGENT_SOCK points at its RPC socket. Team state lives',
      'under .agent/ (roster.md, roles/, status/, session.json).',
    }, ' ')
    local res, serr = M.spawn('main', { cmd = cmd, prompt = prime })
    if not res then
      vim.notify('agent-cockpit: main agent failed to start: ' .. tostring(serr),
        vim.log.levels.WARN)
      return
    end
    M.focus('main')
  end)
end

function M._crash_prompt(id, task_file)
  local base = task_file and ('Read ' .. task_file .. ' and follow it. ') or ''
  return base .. ('The previous session crashed. Read your status file '
    .. '.agent/status/' .. id .. '.md and continue from where it left off.')
end

function M._maybe_recover()
  local persist = require('agent-cockpit.persist')
  local m = persist.load()
  if not m or m.clean_exit then return nil end
  local mode = (M._config and M._config.auto_recover) or 'ask'
  if mode == 'never' then return nil end
  local function go() M._recover(m) end
  if mode == 'always' then go() return true end
  vim.schedule(function()
    vim.ui.select({ 'yes', 'no' }, {
      prompt = 'agent-cockpit: previous session crashed. Recover workers?',
    }, function(choice)
      if choice == 'yes' then go() else M._open_main_agent() end
    end)
  end)
  return true
end

function M._recover(m)
  for _, w in ipairs(m.workers or {}) do
    local preset = presets.resolve(w.agent, root(), w.op_overrides)
    local res, serr
    if preset.resume_suffix and w.session_id then
      -- Best path: resume the worker's OWN session (keeps original args,
      -- e.g. --auto) instead of a cwd-scoped "most recent" resume.
      res, serr = M.spawn(w.id, {
        cmd = w.cmd .. ' ' .. preset.resume_suffix:gsub('{session}', w.session_id),
        cwd = w.cwd, op_overrides = w.op_overrides, skip_session_capture = true })
    elseif preset.resume then
      res, serr = M.spawn(w.id, { cmd = preset.resume, cwd = w.cwd,
        op_overrides = w.op_overrides, skip_session_capture = true })
    else
      -- No resume template: respawn the original cmd. The crash-note prompt
      -- is only appended when the worker had a task file; a bare cmd like
      -- `cat` would treat the prompt text as a filename and exit.
      res, serr = M.spawn(w.id, { cmd = w.cmd, cwd = w.cwd, task_file = w.task_file,
        prompt = w.task_file and M._crash_prompt(w.id, w.task_file) or nil,
        op_overrides = w.op_overrides })
    end
    if not res then
      vim.notify(('agent-cockpit: recovery failed for worker %s: %s')
        :format(w.id, tostring(serr)), vim.log.levels.WARN)
    end
    if res and w.hidden then
      local e = reg.get(w.id)
      if e then e.hidden = true end
    end
  end
  if m.main_file then M.edit(m.main_file) end
  if m.foreground and reg.get(m.foreground) then M.focus(m.foreground) end
  -- Layout state: mode + focused slot + review area. Runs after the
  -- foreground restore so the recorded mode wins over focus side effects.
  if m.layout_mode == 'B' then
    zones._focused = m.focused
    zones.set_mode('B')
  else
    zones.set_mode('A')
  end
  zones.restore_review(m.review)
end

local function default_prompt(id, task_file)
  return ('Read %s and follow it. Keep .agent/status/%s.md current: its first'
    .. ' line must be exactly `state: working` (later `state: blocked` or'
    .. ' `state: done`), followed by a one-line summary.'):format(task_file, id)
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

  -- Snapshot kimi's session index BEFORE spawning so the worker's own
  -- session id can be captured afterwards (kimi creates it on first message).
  -- Skipped on resume spawns: resuming creates no new index record, and a
  -- live capture could misclaim another worker's fresh session.
  local sessions = require('agent-cockpit.sessions')
  local cwd = o.cwd or root()
  local before = head == 'kimi' and not o.skip_session_capture
    and sessions.kimi_session_ids(cwd) or nil

  local buf = vim.api.nvim_create_buf(false, true)
  local job
  vim.api.nvim_buf_call(buf, function()
    job = vim.fn.termopen(cmd, {
      cwd = cwd,
      on_exit = function()
        vim.schedule(function()
          local e = reg.get(id)
          if not e then return end -- killed deliberately: no alarm
          require('agent-cockpit.dashboard').note_death(id)
        end)
      end,
    })
  end)
  if job <= 0 then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    return err('termopen failed for: ' .. cmd)
  end
  -- Name AFTER termopen: termopen renames the buffer to term://...
  vim.api.nvim_buf_set_name(buf, 'agent://worker/' .. id)
  reg.add(id, {
    id = id, buf = buf, job = job,
    agent = head, cmd = cmd, cwd = cwd, role = o.role,
    task_file = o.task_file, op_overrides = o.op_overrides or {},
    hidden = o.hidden or false,
  })
  if before then
    -- A unique substring of the initial prompt disambiguates concurrent
    -- same-cwd kimi spawns (the wire log's first user message is the prompt).
    local match
    if o.task_file then
      match = ('.agent/status/%s.md'):format(id)
    elseif prompt then
      match = prompt:match('[^\n]+'):sub(1, 40)
    end
    M._claimed_sessions = M._claimed_sessions or {}
    sessions.capture_kimi(cwd, before, function(session_id)
      local e = reg.get(id)
      if not e then return end
      e.session_id = session_id
      require('agent-cockpit.persist').save()
    end, { match = match, claimed = M._claimed_sessions })
  end
  require('agent-cockpit.persist').save()
  if prompt then
    -- Deliver the initial prompt through the terminal, not the command line:
    -- kimi rejects positional prompt args, and a deferred chansend works for
    -- every CLI (the pty queues input until the program reads it). The delay
    -- must cover slow TUI boots (kimi takes several seconds).
    local delay = (M._config and M._config.prompt_delay) or 5000
    vim.defer_fn(function()
      local e = reg.get(id)
      if not (e and reg.alive(e)) then return end
      M.send(id, prompt)
      -- Submit separately, and retry: agent TUIs treat a CR arriving in the
      -- same input burst as a newline, and a CR sent while the TUI is still
      -- booting is swallowed entirely. Empty submits are harmless no-ops.
      for _, d in ipairs({ 300, 1500, 3000 }) do
        vim.defer_fn(function()
          local e2 = reg.get(id)
          if e2 and reg.alive(e2) then M.op(id, 'submit') end
        end, d)
      end
    end, delay)
  end
  zones.arrange()
  pcall(function() require('agent-cockpit.dashboard').render() end)
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
  local ok, zerr = zones.focus(id)
  if not ok then return err(zerr) end
  M._foreground = id
  require('agent-cockpit.persist').save()
  return true
end

function M.jump(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  zones.jump(id)
  return true
end

function M.layout(mode)
  if mode then
    zones.set_mode(mode)
    require('agent-cockpit.persist').save()
  end
  return { mode = zones.mode, focused = zones._focused }
end

function M.team_apply()
  local res, terr = require('agent-cockpit.team').apply(root())
  if not res then return err(terr) end
  return res
end

function M.team_dump(name)
  local res, terr = require('agent-cockpit.team').dump(root(), name)
  if not res then return err(terr) end
  return res
end

function M.team_raise(name)
  local res, terr = require('agent-cockpit.team').raise(root(), name)
  if not res then return err(terr) end
  return res
end

function M.dashboard()
  require('agent-cockpit.dashboard').toggle()
  require('agent-cockpit.persist').save()
  return true
end

function M.diff(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  local lines = vim.fn.systemlist({ 'git', '-C', e.cwd, 'diff', 'HEAD' })
  if vim.v.shell_error ~= 0 then
    return err('git diff failed: ' .. table.concat(lines, '\n'))
  end
  if #lines == 0 or (#lines == 1 and lines[1] == '') then
    lines = { '(no uncommitted changes in ' .. e.cwd .. ')' }
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = 'diff'
  vim.bo[buf].bufhidden = 'wipe'
  zones.show_in_review(buf, 'file')
  return true
end

--- Install an agent-ctl shim into a PATH directory so cmd.exe/PowerShell
--- users (e.g. codex on Windows) can call the bridge without knowing the
--- plugin path. Returns the directory used.
function M.install(dir)
  dir = dir or (vim.fn.has('win32') == 1
    and ((vim.env.USERPROFILE or vim.env.HOME) .. '\\bin')
    or ((vim.env.HOME or '~') .. '/.local/bin'))
  vim.fn.mkdir(dir, 'p')
  local src = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
  local bin = vim.fn.fnamemodify(src, ':h:h:h') .. '/bin'
  if vim.fn.has('win32') == 1 then
    local shim = dir .. '\\agent-ctl.cmd'
    local f = io.open(shim, 'w')
    if not f then return err('cannot write ' .. shim) end
    f:write('@echo off\r\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "'
      .. bin:gsub('/', '\\') .. '\\agent-ctl.ps1" %*\r\n')
    f:close()
  else
    local target = dir .. '/agent-ctl'
    pcall(vim.uv.fs_unlink, target)
    if not vim.uv.fs_symlink(bin .. '/agent-ctl', target) then
      return err('cannot symlink into ' .. dir)
    end
  end
  return dir
end

function M.hide(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  zones.hide(id)
  require('agent-cockpit.persist').save()
  return true
end

function M.kill(id)
  local e, eerr = live_entry(id)
  if not e then return err(eerr) end
  -- Delete the buffer BEFORE stopping the job: on Windows, headless nvim
  -- segfaults when a terminal job's exit event fires for a buffer that is
  -- (or was) shown in a window; force-deleting the term buffer first kills
  -- the job through channel teardown instead.
  if vim.api.nvim_buf_is_valid(e.buf) then
    pcall(vim.api.nvim_buf_delete, e.buf, { force = true })
  end
  pcall(vim.fn.jobstop, e.job)
  reg.remove(id)
  if M._foreground == id then M._foreground = nil end
  zones.arrange()
  pcall(function() require('agent-cockpit.dashboard').render() end)
  require('agent-cockpit.persist').save()
  return true
end

function M.edit(path)
  zones.edit(path)
  require('agent-cockpit.persist').save()
  return true
end

local function read_status(id)
  local path = root() .. '/.agent/status/' .. id .. '.md'
  local f = io.open(path, 'r')
  if not f then return 'unknown', '' end
  local body = f:read('a') or ''
  f:close()
  -- Scan the first 10 lines for a state line: optional bullet, optional
  -- backticks, case-insensitive `state: <token>`. Markdown headers are
  -- skipped: `# Status: dev` is a title, not a state.
  local ln = 0
  for line in (body .. '\n'):gmatch('([^\n]*)\n') do
    ln = ln + 1
    if ln > 10 then break end
    if not line:match('^%s*#') then
      local token = line:match("^%s*[-*]?%s*`?[Ss][Tt][Aa][Tt][Ee]`?%s*:%s*`?(%w[%w_-]*)")
      if token then
        local summary = vim.trim((body:gsub(vim.pesc(line), '', 1)))
        return token:lower(), summary
      end
    end
  end
  return 'unknown', vim.trim(body)
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
  -- Submit separately and slightly later: agent TUIs (kimi) treat a CR
  -- arriving in the same input burst as the text as a literal newline
  -- instead of submit. A short delay lets the editor settle first.
  vim.defer_fn(function()
    local e = reg.get(id)
    if e and reg.alive(e) then M.op(id, 'submit') end
  end, 300)
  return true
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
    role = e.role,
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
