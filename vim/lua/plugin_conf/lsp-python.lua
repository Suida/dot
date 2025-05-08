local M = {}

M.setup = function(lspconfig, on_attach, lsp_flags, capabilities)
  lspconfig.pyright.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
    settings = {
      pyright = {
        disableOrganizeImports = true,
      },
    },
  }

  lspconfig.ruff.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
    init_options = {
      settings = {
        showSyntaxErrors = false
      },
    },
  }

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client == nil then
        return
      end
      if client.name == 'ruff' then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
    end,
    desc = 'LSP: Disable hover capability from Ruff',
  })
end

return M
