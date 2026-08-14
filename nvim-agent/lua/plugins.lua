-- Plugin specs for lazy.nvim. snacks.nvim is the only dependency.
local src = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
local repo = vim.fn.fnamemodify(src, ':h:h:h') -- <repo>/nvim-agent/lua/plugins.lua -> <repo>
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      explorer = { enabled = true },
      notify = { enabled = true },
      input = { enabled = true },
      terminal = { enabled = true },
    },
  },
  {
    dir = repo .. '/agent-cockpit.nvim',
    name = 'agent-cockpit',
    lazy = false,
    dependencies = { 'folke/snacks.nvim' },
    config = function() require('agent-cockpit').setup({}) end,
  },
}
