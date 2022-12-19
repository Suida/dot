local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local ret = require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- Git
  use 'tpope/vim-fugitive'
  use {'airblade/vim-gitgutter', cond = 'GitGutterToggle' }
  -- Outlook
  use 'majutsushi/tagbar'
  use {
    'sonph/onehalf',
    rtp = 'vim/',
    config = function()
      vim.cmd[[
        colorscheme onehalflight
        " Hide (~) at the end of buffer
        highlight NonText guifg=bg
        highlight EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg
      ]]
    end
  }
  use 'itchyny/lightline.vim'
  use 'voldikss/vim-floaterm'
  use 'tomtom/tcomment_vim'

  if ensure_packer then
    -- require('packer').sync()
  end
end)


-- Set up lspconfig.
local lspconfig = require'lspconfig'

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local language_servers = {'pyright', 'svlangserver', 'clangd', }

for _, server in ipairs(language_servers) do
  lspconfig[server].setup {
    capabilities = capabilities
  }
end


-- Set up nvim-cmp
local cmp = require'cmp'

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-f>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
}

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


-- Set up tagbar
function setup_tagbar ()
  vim.g.tagbar_left = 1
  vim.g.tagbar_width = 32
  vim.g.tagbar_compact = 1
  vim.g.tagbar_sort = 0
  vim.g.typescript_use_builtin_tagbar_defs = 0
  vim.g.tagbar_type_cpp = {
    kinds = {
      'c:classes:0:1',
      'd:macros:0:1',
      'e:enumerators:0:0',
      'f:functions:0:1',
      'g:enumeration:0:1',
      'l:local:0:1',
      'm:members:0:1',
      'n:namespaces:0:1',
      'p:functions_prototypes:0:1',
      's:structs:0:1',
      't:typedefs:0:1',
      'u:unions:0:1',
      'v:global:0:1',
      'x:external:0:1'
    },
    sro        = '::',
    kind2scope = {
      g = 'enum',
      n = 'namespace',
      c = 'class',
      s = 'struct',
      u = 'union'
    },
    scope2kind = {
      enum      = 'g',
      namespace = 'n',
      class     = 'c',
      struct    = 's',
      union     = 'u',
    }
  }
  vim.keymap.set('n', '<leader>w', ':TagbarToggle<CR>', { noremap = true })
end
setup_tagbar()


-- Setup lightline
function setup_lightline ()
  vim.g.lightline = {
    colorscheme = 'powerline',
    background = 'light',
    active = {
      left = {
        { 'mode', 'paste' },
        { 'gitbranch', 'readonly', 'filename', 'modified' }
      }
    },
    component_function = {
      gitbranch = 'EmojiedFugitiveHead'
    },
    separator = { left = "", right = "" },
    subseparator = { left = "", right = "" },
    tabline_separator = { left = "", right = "" },
    tabline_subseparator = { left = "", right = "" },
  }

  vim.g.EmojiedFugitiveHead = function ()
    return ' ' .. vim.fn.FugitiveHead()
  end
end
setup_lightline()


-- Set up floaterm
function setup_floaterm ()
  if vim.fn.has('unix') or vim.fn.has('macunix') then
    vim.g.floaterm_shell='/usr/bin/zsh'
  elseif has('win32') then
    vim.g.floaterm_shell=[[C:\Program Files\PowerShell\7\pwsh.exe]]
  end
  vim.g.floaterm_width = 0.8
  vim.g.floaterm_height = 0.8
  vim.keymap.set('n', '<C-t>t', [[:FloatermToggle<CR>]], { noremap = true, silent = true})
  vim.keymap.set('n', '<C-t>n', [[:FloatermNew<CR>]], { noremap = true, silent = true})
  vim.keymap.set('n', '<C-t>k', [[:FloatermKill<CR>]], { noremap = true, silent = true})
  vim.keymap.set('n', '<C-t>]', [[:FloatermNext<CR>]], { noremap = true, silent = true})
  vim.keymap.set('n', '<C-t>[', [[:FloatermPrev<CR>]], { noremap = true, silent = true})
  vim.keymap.set('t', '<C-t>t', [[<C-\><C-n>:exe "sleep 100m \| FloatermToggle"<CR>]], { noremap = true, silent = true})
  vim.keymap.set('t', '<C-t>n', [[<C-\><C-n>:exe "sleep 100m \| FloatermNew"<CR>]], { noremap = true, silent = true})
  vim.keymap.set('t', '<C-t>k', [[<C-\><C-n>:exe "sleep 100m \| FloatermKill"<CR>]], { noremap = true, silent = true})
  vim.keymap.set('t', '<C-t>]', [[<C-\><C-n>:exe "sleep 100m \| FloatermNext"<CR>]], { noremap = true, silent = true})
  vim.keymap.set('t', '<C-t>[', [[<C-\><C-n>:exe "sleep 100m \| FloatermPrev"<CR>]], { noremap = true, silent = true})
end
setup_floaterm()


return ret
