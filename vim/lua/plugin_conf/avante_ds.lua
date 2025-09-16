local avante_status_ok, avante = pcall(require, 'avante')
if not avante_status_ok then
  return
end

avante.setup {
  provider = 'deepseek',
  auto_suggestions_provider = 'deepseek',
  behaviour = {
    enable_cursor_planning_mode = true, -- enable cursor planning mode!
  },
  windows = {
    position = "right",
    wrap = true, -- similar to vim.o.wrap
    width = 45,
    ask = {
      floating = true, -- Open the 'AvanteAsk' prompt in a floating window
      start_insert = false, -- Start insert mode when opening the ask window
      border = "rounded",
      ---@type "ours" | "theirs"
      focus_on_apply = "ours", -- which diff to focus after applying
    },
  },
  providers = {
    deepseek = {
      __inherited_from = "openai",
      api_key_name = "DEEPSEEK_API_KEY",
      endpoint = "https://api.deepseek.com",
      model = "deepseek-chat",
      timeout = 30000,
    },
  },
  mappings = {
    submit = {
      normal = "<C-g>",
      insert = "<C-g>",
    },
  },
}

local opts = { noremap = true, silent = true }
vim.keymap.set({ 'n', 'i', 't' }, '<A-a>', function() avante.toggle() end, opts)
