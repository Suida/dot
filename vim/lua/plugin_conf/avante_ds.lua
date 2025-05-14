local avante_status_ok, avante = pcall(require, 'avante')
if not avante_status_ok then
  return
end

avante.setup {
  provider = 'deepseek',
  auto_suggestions_provider = 'deepseek',
  cursor_applying_provider = 'groq',
  behaviour = {
    enable_cursor_planning_mode = true, -- enable cursor planning mode!
  },
  windows = {
    position = "right",
    wrap = false, -- similar to vim.o.wrap
    width = 40,
    ask = {
      floating = false, -- Open the 'AvanteAsk' prompt in a floating window
      start_insert = false, -- Start insert mode when opening the ask window
      border = "rounded",
      ---@type "ours" | "theirs"
      focus_on_apply = "ours", -- which diff to focus after applying
    },
  },
  vendors = {
    deepseek = {
      __inherited_from = "openai",
      api_key_name = "DEEPSEEK_API_KEY",
      endpoint = "https://api.deepseek.com",
      model = "deepseek-coder",
      timeout = 30000,
    },
    groq = { -- define groq provider
      __inherited_from = 'openai',
      api_key_name = 'GROQ_API_KEY',
      endpoint = 'https://api.groq.com/openai/v1/',
      model = 'llama-3.3-70b-versatile',
      max_completion_tokens = 131072, -- remember to increase this value, otherwise it will stop generating halfway
      timeout = 30000,
    },
  },
}

