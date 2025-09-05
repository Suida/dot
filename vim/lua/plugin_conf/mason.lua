local mason_status_ok, mason = pcall(require, 'mason')
if not mason_status_ok then
  return
end

local mason_lsp_status_ok, mason_lsp = pcall(require, 'mason-lspconfig')
if not mason_lsp_status_ok then
  return
end

mason.setup{}

