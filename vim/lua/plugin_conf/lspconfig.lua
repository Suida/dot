
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, _)
end

local bufopts = { noremap = true, silent = true, }
vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, bufopts)
vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
vim.keymap.set('n', '<leader>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, bufopts)
vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
vim.keymap.set('n', '<leader>ft', function() vim.lsp.buf.format { async = true } end, bufopts)

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
  'verible', 'clangd', 'ts_ls', 'rust_analyzer', 'jsonls',
  'vimls', 'texlab', 'cmake',
}

for _, server in ipairs(language_servers) do
  vim.lsp.config(server, {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  })
vim.lsp.enable(server)
end

vim.lsp.config("clangd", {
  cmd = { 'clangd', '--header-insertion=never' },
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
})
vim.lsp.enable("clangd")

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server", "--metapath", "~/.cache/lua-language-server/meta/" },
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = {
          'vim',
        }
      },
      workspace = {
        library = {
          vim.api.nvim_get_runtime_file('', true),
        }
      }
    }
  },
})
vim.lsp.enable("lua_ls")

vim.lsp.config("verible", {
  cmd = {
    'verible-verilog-ls',
    '--wrap_spaces',
    '2',
    '--rules',
    '-explicit-parameter-storage-type,-no-tabs,-unpacked-dimensions-range-ordering,-line-length',
  },
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
})
vim.lsp.enable("verible")

vim.lsp.config("texlab", {
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
})
vim.lsp.enable("texlab")

require("plugin_conf.lsp-python").setup(on_attach, lsp_flags, capabilities)
