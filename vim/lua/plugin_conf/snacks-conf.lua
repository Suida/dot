local snacks_status_ok, snacks = pcall(require, 'snacks')
if not snacks_status_ok then
  return
end
local utils = require 'user.utils';

local dashboard_opts = {
  enabled = true,
  width = 60,
  row = nil,                                                                   -- dashboard position. nil for center
  col = nil,                                                                   -- dashboard position. nil for center
  pane_gap = 4,                                                                -- empty columns between vertical panes
  autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
  -- These settings are used by some built-in sections
  preset = {
    -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
    ---@type fun(cmd:string, opts:table)|nil
    pick = nil,
    keys = {
      { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "s", desc = "Restore Session", section = "session" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
      { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
    },
    -- Used by the `header` section
    header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
  },
  -- item field formatters
  sections = {
    { section = "header" },
    {
      pane = 2,
      section = "terminal",
      cmd = vim.fn.has('win32') and "echo Hello!" or "colorscript -e square",
      height = 7,
      padding = 1,
    },
    { section = "keys", gap = 1, padding = 2 },
    { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
    { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
    { pane = 2, section = "startup", padding = 1 },
  },

}

snacks.setup {
  animate = {
    enabled = vim.fn.has("nvim-0.10") == 1,
    style = "out",
    easing = "linear",
    duration = {
      step = 20,   -- ms per step
      total = 300, -- maximum duration
    },
  },
  bigfile = { enabled = true },
  dashboard = dashboard_opts,
  explorer = { enabled = true },
  image = { enabled = true },
  indent = { enabled = true },
  input = {
    width = 100,
    enabled = true,
  },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  picker = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  statuscolumn = {
    enabled = true,
    left = { "mark", "sign", }, -- priority of signs on the left (high to low)
    right = { "fold", "git", }, -- priority of signs on the right (high to low)
    folds = {
      open = true,              -- show open fold icons
      git_hl = false,           -- use Git Signs hl for fold icons
    },
    git = {
      -- patterns to match Git signs
      patterns = { "GitSign", "MiniDiffSign" },
    },
    refresh = 50, -- refresh at most every 50ms
  },
  words = { enabled = true },
  styles = {
    notification = {
      wo = { wrap = true } -- Wrap notifications
    }
  },
  terminal = {
    shell = { "pwsh", "-nol" },
  },
}

local keymap_opts = {
  silent = true
}

local keymap_tbl = {
  -- Top Pickers & Explorer
  { "<leader><space>", function() snacks.picker.smart() end,                                   desc = "Smart Find Files" },
  { "<leader>,",       function() snacks.picker.buffers() end,                                 desc = "Buffers" },
  { "<leader>/",       function() snacks.picker.grep() end,                                    desc = "Grep" },
  { "<leader>:",       function() snacks.picker.command_history() end,                         desc = "Command History" },
  { "<leader>n",       function() snacks.picker.notifications() end,                           desc = "Notification History" },
  { "<leader>e",       function() snacks.explorer() end,                                       desc = "File Explorer" },
  -- find
  { "<leader>fb",      function() snacks.picker.buffers() end,                                 desc = "Buffers" },
  { "<leader>fc",      function() snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
  { "<leader>ff",      function() snacks.picker.files() end,                                   desc = "Find Files" },
  { "<leader>fg",      function() snacks.picker.git_files() end,                               desc = "Find Git Files" },
  { "<leader>fp",      function() snacks.picker.projects() end,                                desc = "Projects" },
  { "<leader>fr",      function() snacks.picker.recent() end,                                  desc = "Recent" },
  -- git
  { "<leader>gc",      function() snacks.picker.git_branches() end,                            desc = "Git Branches" },
  { "<leader>gl",      function() snacks.picker.git_log() end,                                 desc = "Git Log" },
  { "<leader>gL",      function() snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
  { "<leader>gs",      function() snacks.picker.git_status() end,                              desc = "Git Status" },
  { "<leader>gf",      function() snacks.picker.git_log_file() end,                            desc = "Git Log File" },
  -- Grep
  { "<leader>sb",      function() snacks.picker.lines() end,                                   desc = "Buffer Lines" },
  { "<leader>sB",      function() snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
  { "<leader>sg",      function() snacks.picker.grep() end,                                    desc = "Grep" },
  { "<leader>sw",      function() snacks.picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" } },
  -- search
  { '<leader>s"',      function() snacks.picker.registers() end,                               desc = "Registers" },
  { '<leader>s/',      function() snacks.picker.search_history() end,                          desc = "Search History" },
  { "<leader>sa",      function() snacks.picker.autocmds() end,                                desc = "Autocmds" },
  { "<leader>sb",      function() snacks.picker.lines() end,                                   desc = "Buffer Lines" },
  { "<leader>sc",      function() snacks.picker.command_history() end,                         desc = "Command History" },
  { "<leader>sC",      function() snacks.picker.commands() end,                                desc = "Commands" },
  { "<A-p>",           function() snacks.picker.commands() end,                                desc = "Commands" },
  { "<leader>sd",      function() snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
  { "<leader>sD",      function() snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
  { "<leader>sh",      function() snacks.picker.help() end,                                    desc = "Help Pages" },
  { "<leader>sH",      function() snacks.picker.highlights() end,                              desc = "Highlights" },
  { "<leader>si",      function() snacks.picker.icons() end,                                   desc = "Icons" },
  { "<leader>sj",      function() snacks.picker.jumps() end,                                   desc = "Jumps" },
  { "<leader>sk",      function() snacks.picker.keymaps() end,                                 desc = "Keymaps" },
  { "<leader>sm",      function() snacks.picker.marks() end,                                   desc = "Marks" },
  { "<leader>sM",      function() snacks.picker.man() end,                                     desc = "Man Pages" },
  { "<leader>sp",      function() snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec" },
  { "<leader>sq",      function() snacks.picker.qflist() end,                                  desc = "Quickfix List" },
  { "<leader>sR",      function() snacks.picker.resume() end,                                  desc = "Resume" },
  { "<leader>su",      function() snacks.picker.undo() end,                                    desc = "Undo History" },
  { "<leader>uC",      function() snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
  -- LSP
  { "gd",              function() snacks.picker.lsp_definitions() end,                         desc = "Goto Definition" },
  { "gD",              function() snacks.picker.lsp_declarations() end,                        desc = "Goto Declaration" },
  { "gr",              function() snacks.picker.lsp_references() end,                          desc = "References",               nowait = true, },
  { "gi",              function() snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation" },
  { "gy",              function() snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition" },
  { "<leader>ss",      function() snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
  { "<leader>sS",      function() snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },
  -- Other
  { "<leader>z",       function() snacks.zen() end,                                            desc = "Toggle Zen Mode" },
  { "<leader>Z",       function() snacks.zen.zoom() end,                                       desc = "Toggle Zoom" },
  { "<leader>.",       function() snacks.scratch() end,                                        desc = "Toggle Scratch Buffer" },
  { "<leader>S",       function() snacks.scratch.select() end,                                 desc = "Select Scratch Buffer" },
  { "<leader>n",       function() snacks.notifier.show_history() end,                          desc = "Notification History" },
  { "<leader>bd",      function() snacks.bufdelete() end,                                      desc = "Delete Buffer" },
  { "<leader>cR",      function() snacks.rename.rename_file() end,                             desc = "Rename File" },
  { "<leader>gB",      function() snacks.gitbrowse() end,                                      desc = "Git Browse",               mode = { "n", "v" } },
  { "<leader>un",      function() snacks.notifier.hide() end,                                  desc = "Dismiss All Notifications" },
  { "]]",              function() snacks.words.jump(vim.v.count1) end,                         desc = "Next Reference",           mode = { "n", "t" } },
  { "[[",              function() snacks.words.jump(-vim.v.count1) end,                        desc = "Prev Reference",           mode = { "n", "t" } },
  {
    "<leader>N",
    desc = "Neovim News",
    function()
      snacks.win({
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      })
    end,
  }
}

for _, value in ipairs(keymap_tbl) do
  if not value['mode'] then
    value['mode'] = { 'n' }
  end
  vim.keymap.set(value['mode'], value[1], value[2], {
    desc = value['desc'],
    silent = true,
  })
end

local explorer_opts = {
  finder = "explorer",
  sort = { fields = { "sort" } },
  supports_live = true,
  tree = true,
  watch = true,
  diagnostics = true,
  diagnostics_open = false,
  git_status = true,
  git_status_open = false,
  git_untracked = true,
  follow_file = true,
  focus = "list",
  auto_close = false,
  jump = { close = false },
  layout = {
    preset = "sidebar",
    preview = false,
    layout = { position = "left" },
  },
  -- to show the explorer to the right, add the below to
  -- your config under `opts.picker.sources.explorer`
  -- layout = { layout = { position = "right" } },
  formatters = {
    file = { filename_only = true },
    severity = { pos = "right" },
  },
  matcher = { sort_empty = false, fuzzy = false },
  config = function(opts)
    return require("snacks.picker.source.explorer").setup(opts)
  end,
  win = {
    list = {
      keys = {
        ["<BS>"] = "explorer_up",
        ["l"] = "confirm",
        ["h"] = "explorer_close", -- close directory
        ["a"] = "explorer_add",
        ["d"] = "explorer_del",
        ["r"] = "explorer_rename",
        ["c"] = "explorer_copy",
        ["m"] = "explorer_move",
        ["o"] = "confirm",
        ["s"] = "explorer_open", -- open with system application
        ["P"] = "toggle_preview",
        ["y"] = { "explorer_yank", mode = { "n", "x" } },
        ["p"] = "explorer_paste",
        ["u"] = "explorer_update",
        ["<leader>/"] = "picker_grep",
        ["t"] = "tab",
        ["<C-t>"] = "tab",
        ["."] = "tcd",
        ["I"] = "toggle_ignored",
        ["H"] = "toggle_hidden",
        ["Z"] = "explorer_close_all",
        ["]c"] = "explorer_git_next",
        ["[c"] = "explorer_git_prev",
        ["]d"] = "explorer_diagnostic_next",
        ["[d"] = "explorer_diagnostic_prev",
        ["]w"] = "explorer_warn_next",
        ["[w"] = "explorer_warn_prev",
        ["]e"] = "explorer_error_next",
        ["[e"] = "explorer_error_prev",
        ["<C-c>"] = "<Esc>",
      },
    },
  },
}

vim.keymap.set('n', '<leader>e', function() snacks.picker.explorer(explorer_opts) end, keymap_opts)

vim.keymap.set('n', '<leader>fF', function()
  snacks.picker.files {
    finder = "files",
    format = "file",
    show_empty = true,
    hidden = true,
    ignored = true,
    follow = false,
    supports_live = true,
  }
end, keymap_opts)

local function contains(arr, str)
    for _, v in ipairs(arr) do
        if v == str then
            return true
        end
    end
    return false
end

local __agent_cmd = nil;

__agent_candidates = { 'claude', 'codex', 'opencode', 'kimi', }
__agent_candidates_str = ""

for _, v in ipairs(__agent_candidates) do
  __agent_candidates_str = __agent_candidates_str .. "|" .. v
end

__agent_candidates_str = __agent_candidates_str:sub(2)

vim.fn.agent_candidate_completion = function()
  return __agent_candidates
end

local cmd_suffix = ''

if utils.get_os_type() == 'win32' then
  cmd_suffix = "pwsh -nol -c "
else
  cmd_suffix = ""
end

local function _toggle_agent_terminal(agent)
  -- Snacks.terminal.toggle("pwsh -nol -c " .. agent, {
  Snacks.terminal.toggle(agent, {
    env = {
      TERM = "dumb",
    },
    win = {
      ---@field style? string merges with config from `Snacks.config.styles[style]`
      ---@field show? boolean Show the window immediately (default: true)
      ---@field footer_keys? boolean|string[] Show keys footer. When string[], only show those keys with lhs (default: false)
      ---@field height? number|fun(self:snacks.win):number Height of the window. Use <1 for relative height. 0 means full height. (default: 0.9)
      ---@field width? number|fun(self:snacks.win):number Width of the window. Use <1 for relative width. 0 means full width. (default: 0.9)
      ---@field min_height? number Minimum height of the window
      ---@field max_height? number Maximum height of the window
      ---@field min_width? number Minimum width of the window
      ---@field max_width? number Maximum width of the window
      ---@field col? number|fun(self:snacks.win):number Column of the window. Use <1 for relative column. (default: center)
      ---@field row? number|fun(self:snacks.win):number Row of the window. Use <1 for relative row. (default: center)
      ---@field minimal? boolean Disable a bunch of options to make the window minimal (default: true)
      ---@field position? "float"|"bottom"|"top"|"left"|"right"|"current"
      ---@field border? "none"|"top"|"right"|"bottom"|"left"|"top_bottom"|"hpad"|"vpad"|"rounded"|"single"|"double"|"solid"|"shadow"|"bold"|string[]|false|true
      ---@field buf? number If set, use this buffer instead of creating a new one
      ---@field file? string If set, use this file instead of creating a new buffer
      ---@field enter? boolean Enter the window after opening (default: false)
      ---@field backdrop? number|false|snacks.win.Backdrop Opacity of the backdrop (default: 60)
      ---@field wo? vim.wo|{} window options
      ---@field bo? vim.bo|{} buffer options
      ---@field b? table<string, any> buffer local variables
      ---@field w? table<string, any> window local variables
      ---@field ft? string filetype to use for treesitter/syntax highlighting. Won't override existing filetype
      ---@field scratch_ft? string filetype to use for scratch buffers
      ---@field keys? table<string, false|string|fun(self: snacks.win)|snacks.win.Keys> Key mappings
      ---@field on_buf? fun(self: snacks.win) Callback after opening the buffer
      ---@field on_win? fun(self: snacks.win) Callback after opening the window
      ---@field on_close? fun(self: snacks.win) Callback after closing the window
      ---@field fixbuf? boolean don't allow other buffers to be opened in this window
      ---@field text? string|string[]|fun():(string[]|string) Initial lines to set in the buffer
      ---@field actions? table<string, snacks.win.Action.spec> Actions that can be used in key mappings
      ---@field resize? boolean Automatically resize the window when the editor is resized
      ---@field stack? boolean When enabled, multiple split windows with the same position will be stacked together (useful for terminals)
      position = "right",
      height = 0,
      width = function()
        return math.floor(math.max(utils.get_tab_width() * 0.45, 100));
      end,
      auto_insert = false,
      style = {
        title = " Kimi CLI ",
        title_pos = "center",
      },
      title = agent,
      wo = {
        winbar = agent,
      },
      on_buf = function(self)
        vim.keymap.set("t", "<C-j>", "<A-CR>", {
          buffer = self.buf,
          silent = true,
          desc = "Codex: insert newline",
        })
      end,
    },
  })
end

local function toggle_agent_terminal(accept_default)
  if accept_default and contains(__agent_candidates, __agent_cmd) then
    _toggle_agent_terminal(__agent_cmd)
    return
  end
  Snacks.input.input({ 
    prompt = "Select an agent",
    completion = "customlist,v:lua.vim.fn.agent_candidate_completion",
  }, function(agent)
    if (agent == nil) then
      return
    end

    if contains(__agent_candidates, agent) then
      __agent_cmd = agent
      _toggle_agent_terminal(agent)
    else
      Snacks.notify.error("Unsupported agent: [" .. tostring(agent) .. "]. Choose within: " .. __agent_candidates_str)
    end
  end)
end

vim.keymap.set(
  { 'n', 'i', 't' },
  '<M-Backspace>',
  function() toggle_agent_terminal(true) end,
  { desc = 'Toggle Agent', noremap = true, silent = true }
)

vim.keymap.set({ 'n', 'i', 't' }, '<M-9>', toggle_agent_terminal, { desc = 'Select and Toggle Agent ', noremap = true, silent = true })
