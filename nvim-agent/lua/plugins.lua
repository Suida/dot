-- Plugin specs for lazy.nvim. snacks.nvim is the only dependency.
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
}
