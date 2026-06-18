local M = {}

local utils = require 'user.utils'

M.default_agent = 'codex'
M.agent_candidates = { 'claude', 'codex', 'opencode', 'kimi' }
M._tab_states = M._tab_states or {}

local function snacks()
  return require('snacks')
end

local function joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end

  local sep = package.config:sub(1, 1)
  return table.concat({ ... }, sep)
end

local function contains(arr, value)
  for _, item in ipairs(arr) do
    if item == value then
      return true
    end
  end
  return false
end

local function notify_error(message)
  local ok, Snacks = pcall(snacks)
  if ok then
    Snacks.notify.error(message)
  else
    vim.notify(message, vim.log.levels.ERROR)
  end
end

local function valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function job_running(job_id)
  return type(job_id) == 'number' and job_id > 0 and vim.fn.jobwait({ job_id }, 0)[1] == -1
end

local function terminal_job_running(buf, job_id)
  if job_running(job_id) then
    return true
  end
  if not valid_buf(buf) then
    return false
  end
  return job_running(vim.b[buf].terminal_job_id)
end

local function terminal_buf_name(id)
  return 'agent://terminal/' .. id
end

local function find_terminal_buf(id)
  local name = terminal_buf_name(id)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if valid_buf(buf) and (vim.api.nvim_buf_get_name(buf) == name or vim.b[buf].agent_terminal_slot == id) then
      return buf
    end
  end
end

local function current_tab()
  return vim.api.nvim_get_current_tabpage()
end

local function state()
  local tab = current_tab()
  if M._tab_states[tab] == nil then
    M._tab_states[tab] = {
      agent = M.default_agent,
      main = {
        active = 'editor',
        terminals = {},
      },
    }
  end
  local st = M._tab_states[tab]
  st.agent = st.agent or M.default_agent
  st.main = st.main or { active = 'editor', terminals = {} }
  st.main.terminals = st.main.terminals or {}
  return st
end

local function shell_cmd()
  if utils.get_os_type() == 'unix' then
    return vim.o.shell ~= '' and vim.o.shell or '/usr/bin/zsh'
  end
  return 'pwsh.exe'
end

local function is_float(win)
  return win and vim.api.nvim_win_get_config(win).zindex ~= nil
end

local function is_managed_sidebar(win)
  if not valid_win(win) then
    return false
  end
  local snacks_win = vim.w[win].snacks_win
  return vim.w[win].agent_layout_pane == 'left'
    or vim.w[win].agent_layout_pane == 'right'
    or (snacks_win and (snacks_win.position == 'left' or snacks_win.position == 'right'))
    or vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'snacks_layout_box'
end

local function is_main_candidate(win)
  if not valid_win(win) or is_float(win) or is_managed_sidebar(win) then
    return false
  end
  if vim.w[win].snacks_win then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local filetype = vim.bo[buf].filetype
  return filetype ~= 'snacks_picker_input'
    and filetype ~= 'snacks_picker_list'
    and filetype ~= 'snacks_terminal'
end

local function find_main_win()
  local current = vim.api.nvim_get_current_win()
  if is_main_candidate(current) then
    return current
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_main_candidate(win) and vim.w[win].agent_layout_main then
      return win
    end
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_main_candidate(win) then
      return win
    end
  end

  return current
end

local function normalize_window_tags()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local snacks_win = vim.w[win].snacks_win
    if snacks_win and snacks_win.position == 'left' then
      vim.w[win].agent_layout_pane = 'left'
    elseif snacks_win and snacks_win.position == 'right' then
      vim.w[win].agent_layout_pane = 'right'
    end

    if not is_main_candidate(win) then
      vim.w[win].agent_layout_main = false
      vim.w[win].snacks_main = false
    end
  end
end

local function remember_main()
  normalize_window_tags()
  local st = state()
  local win = find_main_win()
  if valid_win(win) then
    st.main.win = win
    vim.w[win].agent_layout_main = true
    vim.w[win].snacks_main = true

    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == '' then
      st.main.editor_buf = buf
    end
  end
  return st.main.win
end

local function startup_has_args()
  return vim.fn.argc(-1) > 0
end

local function launch_agents_path()
  local launch_cwd = M.launch_cwd or vim.fn.getcwd(-1, -1)
  local path = joinpath(launch_cwd, 'AGENTS.md')
  if vim.fn.filereadable(path) == 1 then
    return path
  end
end

local function seed_main_from_launch_file()
  local st = state()
  if st.main.seeded_launch_file or startup_has_args() then
    return
  end

  st.main.seeded_launch_file = true
  local path = launch_agents_path()
  if not path then
    return
  end

  local win = remember_main()
  if valid_win(win) then
    vim.api.nvim_set_current_win(win)
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
  remember_main()
end

local function focus_win(win)
  if valid_win(win) then
    vim.api.nvim_set_current_win(win)
    return true
  end
  return false
end

local function focus_main()
  return focus_win(remember_main())
end

function M.is_agent_tab()
  return vim.t.agent_layout == true
end

function M.explorer_opts()
  return {
    finder = 'explorer',
    sort = { fields = { 'sort' } },
    supports_live = true,
    tree = true,
    watch = true,
    diagnostics = true,
    diagnostics_open = false,
    git_status = true,
    git_status_open = false,
    git_untracked = true,
    follow_file = true,
    focus = 'list',
    auto_close = false,
    jump = { close = false },
    layout = {
      preset = 'sidebar',
      preview = false,
      layout = { position = 'left' },
    },
    formatters = {
      file = { filename_only = true },
      severity = { pos = 'right' },
    },
    matcher = { sort_empty = false, fuzzy = false },
    config = function(opts)
      return require('snacks.picker.source.explorer').setup(opts)
    end,
    win = {
      list = {
        wo = {
          winbar = ' Explorer ',
        },
        keys = {
          ['<BS>'] = 'explorer_up',
          l = 'confirm',
          h = 'explorer_close',
          a = 'explorer_add',
          d = 'explorer_del',
          r = 'explorer_rename',
          c = 'explorer_copy',
          m = 'explorer_move',
          o = 'confirm',
          s = 'explorer_open',
          P = 'toggle_preview',
          y = { 'explorer_yank', mode = { 'n', 'x' } },
          p = 'explorer_paste',
          u = 'explorer_update',
          ['<leader>/'] = 'picker_grep',
          t = 'tab',
          ['<C-t>'] = 'tab',
          ['.'] = 'tcd',
          I = 'toggle_ignored',
          H = 'toggle_hidden',
          Z = 'explorer_close_all',
          [']c'] = 'explorer_git_next',
          ['[c'] = 'explorer_git_prev',
          [']d'] = 'explorer_diagnostic_next',
          ['[d'] = 'explorer_diagnostic_prev',
          [']w'] = 'explorer_warn_next',
          ['[w'] = 'explorer_warn_prev',
          [']e'] = 'explorer_error_next',
          ['[e'] = 'explorer_error_prev',
          ['<C-c>'] = '<Esc>',
        },
      },
    },
  }
end

local function get_agent_explorer()
  local st = state()
  local picker = st.left
  if picker and not picker.closed and picker.on_current_tab and picker:on_current_tab() then
    return picker
  end

  local ok, Snacks = pcall(snacks)
  if not ok or not Snacks.picker then
    return nil
  end

  for _, active in ipairs(Snacks.picker.get({ source = 'explorer' })) do
    if active.on_current_tab and active:on_current_tab() then
      st.left = active
      return active
    end
  end
end

function M.open_explorer(opts)
  local Snacks = snacks()
  opts = vim.tbl_deep_extend('force', M.explorer_opts(), opts or {})
  local picker = get_agent_explorer()
  if picker then
    picker:focus('list', { show = true })
    return picker
  end

  picker = Snacks.picker.explorer(opts)
  state().left = picker
  vim.schedule(function()
    if picker and picker.layout then
      if picker.layout.root and picker.layout.root.win and vim.api.nvim_win_is_valid(picker.layout.root.win) then
        vim.w[picker.layout.root.win].agent_layout_pane = 'left'
      end
      if picker.layout.wins then
        for _, win in pairs(picker.layout.wins) do
          if win.win and vim.api.nvim_win_is_valid(win.win) then
            vim.w[win.win].agent_layout_pane = 'left'
          end
        end
      end
    end
  end)
  return picker
end

function M.toggle_explorer()
  if not M.is_agent_tab() then
    return snacks().picker.explorer(M.explorer_opts())
  end

  remember_main()
  local picker = get_agent_explorer()
  if picker and picker.is_focused and picker:is_focused() then
    picker:close()
    return
  end
  M.open_explorer()
end

function M.agent_terminal_opts(agent)
  return {
    count = 9001,
    env = {
      TERM = 'dumb',
    },
    interactive = true,
    auto_close = false,
    auto_insert = false,
    start_insert = false,
    win = {
      position = 'right',
      height = 0,
      width = function()
        return math.floor(math.max(utils.get_tab_width() * 0.35, 100))
      end,
      enter = false,
      title = agent,
      title_pos = 'center',
      wo = {
        winbar = agent,
      },
      on_buf = function(self)
        vim.b[self.buf].agent_layout_pane = 'right'
        vim.keymap.set('t', '<C-j>', '<A-CR>', {
          buffer = self.buf,
          silent = true,
          desc = 'Agent: insert newline',
        })
      end,
      on_win = function(self)
        vim.w[self.win].agent_layout_pane = 'right'
        vim.w[self.win].agent_layout_main = false
        vim.w[self.win].snacks_main = false
      end,
    },
  }
end

local function executable_or_shell_command(cmd)
  local head = type(cmd) == 'table' and cmd[1] or tostring(cmd):match('^%S+')
  return head and vim.fn.executable(head) == 1
end

function M.open_agent(agent)
  agent = agent or state().agent or M.default_agent
  if not contains(M.agent_candidates, agent) then
    notify_error('Unsupported agent: [' .. tostring(agent) .. ']')
    return
  end

  state().agent = agent
  if not executable_or_shell_command(agent) then
    notify_error('Agent command not found on PATH: ' .. agent)
    return
  end

  local terminal = snacks().terminal.get(agent, M.agent_terminal_opts(agent))
  state().right = terminal
  if terminal and not terminal:valid() then
    terminal:show()
  end
  if terminal and terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
    vim.w[terminal.win].agent_layout_pane = 'right'
  end
  return terminal
end

function M.toggle_agent(accept_default)
  if not M.is_agent_tab() then
    return M.toggle_agent_terminal_normal(accept_default)
  end

  local st = state()
  if accept_default ~= false and contains(M.agent_candidates, st.agent) then
    local terminal = st.right or M.open_agent(st.agent)
    if terminal and terminal:valid() and vim.api.nvim_get_current_win() == terminal.win then
      terminal:hide()
    elseif terminal then
      terminal:show()
      terminal:focus()
    end
    return
  end

  M.select_agent()
end

function M.select_agent()
  local Snacks = snacks()
  Snacks.input.input({
    prompt = 'Select an agent',
    completion = 'customlist,v:lua.vim.fn.agent_candidate_completion',
    default = state().agent or M.default_agent,
  }, function(agent)
    if agent == nil or agent == '' then
      return
    end
    if not contains(M.agent_candidates, agent) then
      Snacks.notify.error('Unsupported agent: [' .. tostring(agent) .. ']. Choose within: ' .. table.concat(M.agent_candidates, '|'))
      return
    end
    state().agent = agent
    if M.is_agent_tab() then
      if state().right and state().right.close then
        state().right:close({ buf = false })
      end
      M.open_agent(agent)
    else
      M.toggle_agent_terminal_normal(false, agent)
    end
  end)
end

function M.toggle_agent_terminal_normal(accept_default, agent)
  agent = agent or state().agent
  if accept_default and contains(M.agent_candidates, agent) then
    return snacks().terminal.toggle(agent, M.agent_terminal_opts(agent))
  end
  return M.select_agent()
end

local function set_main_buf(buf)
  local win = remember_main()
  if valid_win(win) and valid_buf(buf) then
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_set_current_win(win)
    vim.w[win].agent_layout_main = true
    vim.w[win].snacks_main = true
    return true
  end
  return false
end

function M.main_editor()
  if not M.is_agent_tab() then
    return
  end

  local st = state()
  if valid_buf(st.main.editor_buf) then
    set_main_buf(st.main.editor_buf)
  else
    focus_main()
  end
  st.main.active = 'editor'
end

function M.main_terminal(id)
  if not M.is_agent_tab() then
    return M.toggle_terminal_normal(id)
  end

  id = id or vim.v.count1
  local st = state()
  remember_main()

  local slot = st.main.terminals[id] or {}
  if not valid_buf(slot.buf) then
    slot.buf = find_terminal_buf(id) or vim.api.nvim_create_buf(false, true)
    if vim.api.nvim_buf_get_name(slot.buf) == '' then
      vim.api.nvim_buf_set_name(slot.buf, terminal_buf_name(id))
    end
    vim.b[slot.buf].agent_terminal_slot = id
    st.main.terminals[id] = slot
  end

  set_main_buf(slot.buf)
  if not terminal_job_running(slot.buf, slot.job_id) then
    vim.api.nvim_buf_call(slot.buf, function()
      slot.job_id = vim.fn.termopen(shell_cmd())
    end)
  end
  slot.started = true
  st.main.active = 'terminal:' .. id
  vim.cmd.startinsert()
end

local function set_neogit_close_keymap(buf)
  if not valid_buf(buf) or vim.bo[buf].filetype ~= 'NeogitStatus' then
    return
  end
  vim.keymap.set('n', 'q', function()
    require('user.agent_layout').close_git_surface(buf)
  end, { buffer = buf, noremap = true, silent = true, desc = 'Agent layout: close git surface' })
end

function M.main_git()
  if not M.is_agent_tab() then
    return M.neogit_normal()
  end

  local st = state()
  local win = remember_main()
  if valid_win(win) then
    local buf = vim.api.nvim_win_get_buf(win)
    if valid_buf(buf) and vim.bo[buf].filetype ~= 'NeogitStatus' then
      st.main.git_prev_buf = buf
    end
  end
  focus_main()
  require('neogit').open({ kind = 'replace' })
  st.main.active = 'git'
  remember_main()
  vim.schedule(function()
    set_neogit_close_keymap(vim.api.nvim_get_current_buf())
  end)
end

function M.close_git_surface(git_buf)
  local st = state()
  local prev = st.main.git_prev_buf
  if valid_buf(prev) then
    set_main_buf(prev)
  else
    M.main_editor()
  end
  st.main.active = 'editor'
  if valid_buf(git_buf) then
    pcall(vim.api.nvim_buf_delete, git_buf, { force = true })
  end
end

function M.toggle_terminal_normal(id)
  local ok_terms, terms = pcall(require, 'toggleterm.terminal')
  local ok_ui, ui = pcall(require, 'toggleterm.ui')
  if not ok_terms or not ok_ui then
    return
  end

  id = id or vim.v.count1
  local has_open, windows = ui.find_open_windows()
  if has_open then
    ui.close_and_save_terminal_view(windows)
  end
  if #windows == 1 and windows[1].term_id == id then
    return
  end

  local term = terms.get_or_create_term(id)
  ui.update_origin_window(term.window)
  term:toggle()
  if not ui.find_open_windows() then
    ui.save_terminal_view({ term.id }, term.id)
  end
end

function M.toggle_all_terminals_normal()
  if M.is_agent_tab() then
    return M.main_terminal(vim.v.count1)
  end
  vim.cmd.ToggleTermToggleAll()
end

function M.lazygit_normal()
  local ok, Terminal = pcall(function()
    return require('toggleterm.terminal').Terminal
  end)
  if not ok then
    return
  end

  if not M._lazygit then
    M._lazygit = Terminal:new({
      cmd = 'lazygit',
      display_name = 'Lazygit',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'double',
      },
      on_open = function(term)
        vim.cmd('startinsert!')
        vim.keymap.set('n', 'q', '<cmd>close<CR>', { noremap = true, silent = true, buffer = term.bufnr })
        pcall(vim.keymap.del, { 'i', 't' }, 'jk')
      end,
      on_close = function()
        vim.keymap.set({ 'i', 't' }, 'jk', [[<C-\><C-n>]], { noremap = true })
        vim.cmd('startinsert!')
      end,
    })
  end
  M._lazygit:toggle()
end

function M.neogit()
  if M.is_agent_tab() then
    return M.main_git()
  end
  M.neogit_normal()
end

function M.neogit_normal()
  vim.cmd.Neogit()
end

function M.open()
  if vim.env.NVIM_AGENT_LAYOUT_DISABLE == '1' then
    return
  end

  if M.agent_tab and vim.api.nvim_tabpage_is_valid(M.agent_tab) and current_tab() ~= M.agent_tab then
    vim.api.nvim_set_current_tabpage(M.agent_tab)
  end

  if not M.agent_tab or not vim.api.nvim_tabpage_is_valid(M.agent_tab) then
    M.agent_tab = current_tab()
  end

  vim.t.agent_layout = true
  remember_main()
  seed_main_from_launch_file()
  M.open_explorer()
  M.open_agent(state().agent or M.default_agent)
  focus_main()
end

function M.reset()
  if not M.is_agent_tab() and M.agent_tab and vim.api.nvim_tabpage_is_valid(M.agent_tab) then
    vim.api.nvim_set_current_tabpage(M.agent_tab)
  end

  local st = state()
  if st.left and st.left.close then
    pcall(function() st.left:close() end)
  end
  if st.right and st.right.close then
    pcall(function() st.right:close({ buf = false }) end)
  end
  st.left = nil
  st.right = nil
  M.open()
end

function M.close()
  local st = state()
  if st.left and st.left.close then
    pcall(function() st.left:close() end)
  end
  if st.right and st.right.close then
    pcall(function() st.right:close({ buf = false }) end)
  end
  vim.t.agent_layout = false
  M._tab_states[current_tab()] = nil
  if current_tab() == M.agent_tab then
    M.agent_tab = nil
  end
end

function M.setup()
  M.launch_cwd = M.launch_cwd or vim.fn.getcwd(-1, -1)

  vim.fn.agent_candidate_completion = function()
    return M.agent_candidates
  end

  vim.api.nvim_create_user_command('AgentLayoutOpen', function()
    M.open()
  end, { force = true })
  vim.api.nvim_create_user_command('AgentLayoutReset', function()
    M.reset()
  end, { force = true })
  vim.api.nvim_create_user_command('AgentLayoutClose', function()
    M.close()
  end, { force = true })
  vim.api.nvim_create_user_command('AgentMainEditor', function()
    M.main_editor()
  end, { force = true })
  vim.api.nvim_create_user_command('AgentMainTerminal', function(opts)
    M.main_terminal(tonumber(opts.args) or vim.v.count1)
  end, { nargs = '?', force = true })
  vim.api.nvim_create_user_command('AgentMainGit', function()
    M.main_git()
  end, { force = true })

  vim.keymap.set('n', '<leader>gg', function()
    M.neogit()
  end, { desc = 'Git UI', noremap = true, silent = true })

  if not M.agent_tab or not vim.api.nvim_tabpage_is_valid(M.agent_tab) then
    M.agent_tab = current_tab()
    vim.t.agent_layout = true
    state().agent = M.default_agent
    remember_main()
  end

  local group = vim.api.nvim_create_augroup('AgentLayout', { clear = true })
  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    callback = function()
      vim.schedule(function()
        M.open()
      end)
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = group,
    callback = function()
      if M.is_agent_tab() then
        remember_main()
      end
    end,
  })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'NeogitStatus',
    callback = function(args)
      if M.is_agent_tab() then
        vim.schedule(function()
          set_neogit_close_keymap(args.buf)
        end)
      end
    end,
  })
end

return M
