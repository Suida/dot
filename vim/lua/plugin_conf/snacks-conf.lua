local snacks_status_ok, snacks = pcall(require, 'snacks')
if not snacks_status_ok then
  return
end

local dashboard_opts = {
  enabled = true,
  width = 60,
  row = nil, -- dashboard position. nil for center
  col = nil, -- dashboard position. nil for center
  pane_gap = 4, -- empty columns between vertical panes
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
      cmd = "colorscript -e square",
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
      step = 20, -- ms per step
      total = 300, -- maximum duration
    },
  },
  bigfile = { enabled = true },
  dashboard = dashboard_opts,
  explorer = { enabled = true },
  image = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  picker = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  statuscolumn = {
    enabled = true,
    left = { "mark", "sign" }, -- priority of signs on the left (high to low)
    right = { "fold", "git" }, -- priority of signs on the right (high to low)
    folds = {
      open = true, -- show open fold icons
      git_hl = true, -- use Git Signs hl for fold icons
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
}

local keymap_opts = {
  silent = true
}

local keymap_tbl = {
  -- Top Pickers & Explorer
  { "<leader><space>", function() snacks.picker.smart() end, desc = "Smart Find Files" },
  { "<leader>,", function() snacks.picker.buffers() end, desc = "Buffers" },
  { "<leader>/", function() snacks.picker.grep() end, desc = "Grep" },
  { "<leader>:", function() snacks.picker.command_history() end, desc = "Command History" },
  { "<leader>n", function() snacks.picker.notifications() end, desc = "Notification History" },
  { "<leader>e", function() snacks.explorer() end, desc = "File Explorer" },
  -- find
  { "<leader>fb", function() snacks.picker.buffers() end, desc = "Buffers" },
  { "<leader>fc", function() snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
  { "<leader>ff", function() snacks.picker.files() end, desc = "Find Files" },
  { "<leader>fg", function() snacks.picker.git_files() end, desc = "Find Git Files" },
  { "<leader>fp", function() snacks.picker.projects() end, desc = "Projects" },
  { "<leader>fr", function() snacks.picker.recent() end, desc = "Recent" },
  -- git
  { "<leader>gc", function() snacks.picker.git_branches() end, desc = "Git Branches" },
  { "<leader>gl", function() snacks.picker.git_log() end, desc = "Git Log" },
  { "<leader>gL", function() snacks.picker.git_log_line() end, desc = "Git Log Line" },
  { "<leader>gs", function() snacks.picker.git_status() end, desc = "Git Status" },
  { "<leader>gf", function() snacks.picker.git_log_file() end, desc = "Git Log File" },
  -- Grep
  { "<leader>sb", function() snacks.picker.lines() end, desc = "Buffer Lines" },
  { "<leader>sB", function() snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
  { "<leader>sg", function() snacks.picker.grep() end, desc = "Grep" },
  { "<leader>sw", function() snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
  -- search
  { '<leader>s"', function() snacks.picker.registers() end, desc = "Registers" },
  { '<leader>s/', function() snacks.picker.search_history() end, desc = "Search History" },
  { "<leader>sa", function() snacks.picker.autocmds() end, desc = "Autocmds" },
  { "<leader>sb", function() snacks.picker.lines() end, desc = "Buffer Lines" },
  { "<leader>sc", function() snacks.picker.command_history() end, desc = "Command History" },
  { "<leader>sC", function() snacks.picker.commands() end, desc = "Commands" },
  { "<leader>sd", function() snacks.picker.diagnostics() end, desc = "Diagnostics" },
  { "<leader>sD", function() snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
  { "<leader>sh", function() snacks.picker.help() end, desc = "Help Pages" },
  { "<leader>sH", function() snacks.picker.highlights() end, desc = "Highlights" },
  { "<leader>si", function() snacks.picker.icons() end, desc = "Icons" },
  { "<leader>sj", function() snacks.picker.jumps() end, desc = "Jumps" },
  { "<leader>sk", function() snacks.picker.keymaps() end, desc = "Keymaps" },
  { "<leader>sm", function() snacks.picker.marks() end, desc = "Marks" },
  { "<leader>sM", function() snacks.picker.man() end, desc = "Man Pages" },
  { "<leader>sp", function() snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
  { "<leader>sq", function() snacks.picker.qflist() end, desc = "Quickfix List" },
  { "<leader>sR", function() snacks.picker.resume() end, desc = "Resume" },
  { "<leader>su", function() snacks.picker.undo() end, desc = "Undo History" },
  { "<leader>uC", function() snacks.picker.colorschemes() end, desc = "Colorschemes" },
  -- LSP
  { "gd", function() snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
  { "gD", function() snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
  { "gr", function() snacks.picker.lsp_references() end, nowait = true, desc = "References" },
  { "gi", function() snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
  { "gy", function() snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
  { "<leader>ss", function() snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
  { "<leader>sS", function() snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
  -- Other
  { "<leader>z",  function() snacks.zen() end, desc = "Toggle Zen Mode" },
  { "<leader>Z",  function() snacks.zen.zoom() end, desc = "Toggle Zoom" },
  { "<leader>.",  function() snacks.scratch() end, desc = "Toggle Scratch Buffer" },
  { "<leader>S",  function() snacks.scratch.select() end, desc = "Select Scratch Buffer" },
  { "<leader>n",  function() snacks.notifier.show_history() end, desc = "Notification History" },
  { "<leader>bd", function() snacks.bufdelete() end, desc = "Delete Buffer" },
  { "<leader>cR", function() snacks.rename.rename_file() end, desc = "Rename File" },
  { "<leader>gB", function() snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
  { "<leader>un", function() snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  { "]]",         function() snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
  { "[[",         function() snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
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
  vim.keymap.set(value['mode'], value[1], value[2], keymap_opts)
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
    layout = { position = "right" },
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
        ["o"] = "explorer_open", -- open with system application
        ["P"] = "toggle_preview",
        ["y"] = { "explorer_yank", mode = { "n", "x" } },
        ["p"] = "explorer_paste",
        ["u"] = "explorer_update",
        ["<C-c>"] = "tcd",
        ["<leader>/"] = "picker_grep",
        ["<C-t>"] = "terminal",
        ["."] = "explorer_focus",
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
      },
    },
  },
}

vim.keymap.set('n', '<leader>e',  function() snacks.picker.explorer(explorer_opts) end, keymap_opts)

