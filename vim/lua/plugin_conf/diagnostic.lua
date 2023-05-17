local signs = { Error = "🚫", Warn = "🚧", Hint = "💡", Info = "🟦" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

