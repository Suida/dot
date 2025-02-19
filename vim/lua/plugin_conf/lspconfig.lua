local lspconfig_status_ok, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_status_ok then
  return
end

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>ft', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
local cmp_lsp_status_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if not cmp_lsp_status_ok then
  return
end
local capabilities = cmp_lsp.default_capabilities()
local language_servers = {
  'pyright', 'verible', 'clangd', 'ts_ls', 'rust_analyzer', 'jsonls',
  'vimls', 'texlab', 'cmake', -- 'svls',
}

for _, server in ipairs(language_servers) do
  lspconfig[server].setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  }
end

lspconfig.clangd.setup {
  cmd = { 'clangd', '--header-insertion=never' },
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}

-- lspconfig.lua_ls.setup {
--   cmd = { "lua-language-server", "--metapath", "~/.cache/lua-language-server/meta/" },
--   on_attach = on_attach,
--   flags = lsp_flags,
--   capabilities = capabilities,
--   settings = {
--     Lua = {
--       diagnostics = {
--         globals = {
--           'vim',
--         }
--       }
--     }
--   },
-- }
--
lspconfig.verible.setup {
  cmd = {
    'verible-verilog-ls',
    '--wrap_spaces',
    '2',
    '--rules',
    '-explicit-parameter-storage-type,-no-tabs,-unpacked-dimensions-range-ordering',
  },
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
}

lspconfig.texlab.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
  settings = {
    texlab = {
      build = {
        executable = 'tectonic',
        args = {
          "-X",
          "compile",
          "%f",
          "--synctex",
          "--keep-logs",
          "--keep-intermediates"
        },
        onSave = true,
        forwardSearchAfter = true,
        forwardSearch = {
          executable = '~/workspace/github/evince-synctex/evince-synctex.sh',
          args = { 'sync', '%p', '%f', '%l' },
        },
      },
    },
  },
}
