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
  -- Code template
  use 'mattn/emmet-vim'

  -- Git
  use 'tpope/vim-fugitive'
  use {
    'airblade/vim-gitgutter',
    opt = true,
    cmd = {
      'GitGutterToggle',
      'GitGutterNextHunk',
      'GitGutterPrevHunk',
    }
  }
  -- Outlook
  use 'majutsushi/tagbar'
  use {
    'sonph/onehalf',
    rtp = 'vim/',
    config = function()
      vim.cmd.colorscheme'onehalflight'
      -- Hide (~) at the end of buffer
      vim.cmd.highlight'NonText guifg=bg'
      vim.cmd.highlight'EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg'
    end
  }
  use 'itchyny/lightline.vim'
  use 'voldikss/vim-floaterm'
  use 'tomtom/tcomment_vim'

  -- Better move
  use 'easymotion/vim-easymotion'
  use 'andymass/vim-matchup'
  use 'tpope/vim-surround'
  -- Brackets
  use 'jiangmiao/auto-pairs'
  use 'tpope/vim-unimpaired'
  -- Marker
  use 'kshenoy/vim-signature'

  -- Fuzzy finder
  use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end, }
  use 'junegunn/fzf.vim'
  -- Global finder
  use 'brooth/far.vim'
  use 'dyng/ctrlsf.vim'

  -- Session manager
  use 'mhinz/vim-startify'

  -- Indentation line
  use 'Yggdroot/indentLine'
  use 'tpope/vim-sleuth'


  -- Language supports
  -- C/C++
  use {'octol/vim-cpp-enhanced-highlight', ft = {'cpp', 'c'}}
  -- Font-end tool chain
  use {'ap/vim-css-color',ft = { 'css', 'less', 'scss', 'tsx', 'ts', 'vim', 'tmux', }}
  use {'maxmellon/vim-jsx-pretty', ft = { 'tsx', 'jsx', }}
  use 'HerringtonDarkholme/yats.vim'
  use 'posva/vim-vue'
  -- Html preview
  use {'turbio/bracey.vim', ft = { 'html', }}
  -- Markdown syntax and preview
  use 'godlygeek/tabular'
  use 'plasticboy/vim-markdown'
  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
    ft = { 'markdown', 'vim-plug', }
  }

  if ensure_packer then
    require('packer').install()
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


-- Set up lightline
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


-- Set up gitgutter
function setup_gitgutter ()
  vim.g.gitgutter_enabled = 0
  -- <leader>h is used to switch split, while <leader>h* is used in gitgutter,
  -- which leads to unacceptable delay when pressing <leader>h, thus gitggutter key
  -- mappings are disabled and re-mapped.
  vim.g.gitgutter_map_keys = 0
  vim.keymap.set('n', '<leader>gg', ':GitGutterToggle<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', ']c', ':GitGutterNextHunk<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '[c', ':GitGutterPrevHunk<CR>', { noremap = true, silent = true })
end
setup_gitgutter()


-- Set up floaterm
function setup_floaterm ()
  if vim.fn.has('unix') or vim.fn.has('macunix') then
    vim.g.floaterm_shell='/usr/bin/zsh'
  elseif has('win32') then
    vim.g.floaterm_shell=[[C:\Program Files\PowerShell\7\pwsh.exe]]
  end
  vim.g.floaterm_width = 0.8
  vim.g.floaterm_height = 0.8
  vim.keymap.set('n', '<C-t>t', [[:FloatermToggle<CR>]], { noremap = true, silent = true })
  vim.keymap.set('n', '<C-t>n', [[:FloatermNew<CR>]], { noremap = true, silent = true })
  vim.keymap.set('n', '<C-t>k', [[:FloatermKill<CR>]], { noremap = true, silent = true })
  vim.keymap.set('n', '<C-t>]', [[:FloatermNext<CR>]], { noremap = true, silent = true })
  vim.keymap.set('n', '<C-t>[', [[:FloatermPrev<CR>]], { noremap = true, silent = true })
  vim.keymap.set('t', '<C-t>t', [[<C-\><C-n>:exe "sleep 100m \| FloatermToggle"<CR>]], { noremap = true, silent = true })
  vim.keymap.set('t', '<C-t>n', [[<C-\><C-n>:exe "sleep 100m \| FloatermNew"<CR>]], { noremap = true, silent = true })
  vim.keymap.set('t', '<C-t>k', [[<C-\><C-n>:exe "sleep 100m \| FloatermKill"<CR>]], { noremap = true, silent = true })
  vim.keymap.set('t', '<C-t>]', [[<C-\><C-n>:exe "sleep 100m \| FloatermNext"<CR>]], { noremap = true, silent = true })
  vim.keymap.set('t', '<C-t>[', [[<C-\><C-n>:exe "sleep 100m \| FloatermPrev"<CR>]], { noremap = true, silent = true })
end
setup_floaterm()


-- Set up easymotion
function setup_easymotion ()
  vim.keymap.set('n', '<leader>S', '<Plug>(easymotion-s)', { silent = true })
  vim.keymap.set('n', '<leader>W', '<Plug>(easymotion-w)', { silent = true })
  vim.keymap.set('n', '<leader>S', '<Plug>(easymotion-s)', { silent = true })
  vim.keymap.set('n', '<leader>J', '<Plug>(easymotion-j)', { silent = true })
  vim.keymap.set('n', '<leader>K', '<Plug>(easymotion-k)', { silent = true })
end
setup_easymotion()


-- Set up fzf
function setup_fzf ()
  vim.keymap.set('n', 'F', ':FZF<CR>', { noremap = true, silent = true })
  vim.g.fzf_colors = {
    fg =      {'fg', 'Normal'},
    bg =      {'bg', 'Normal'},
    hl =      {'fg', 'Comment'},
    ['fg+'] =     {'fg', 'Cursor', 'CursorColumn', 'Normal'},
    ['bg+'] =     {'bg', 'Cursor', 'CursorColumn'},
    ['hl+'] =     {'fg', 'Statement'},
    info =    {'fg', 'PreProc'},
    border =  {'fg', 'Ignore'},
    prompt =  {'fg', 'Conditional'},
    pointer = {'fg', 'Cursor'},
    marker =  {'fg', 'Keyword'},
    spinner = {'fg', 'Label'},
    header =  {'fg', 'Comment'},
  }
end
setup_fzf()


-- Set up ctrlsf
function setup_ctrlsf ()
  vim.g.ctrlsf_backend = 'rg'
  vim.g.ctrlsf_ignore_dir = {
    '*.log', 
    'tsconfig.json',
    'static', 
    'dist',
    '.vscode',
    '.ycm_extra_conf.py',
  }
  vim.keymap.set('n', '<leader>sf', ':CtrlSF ', { noremap = true })
end
setup_ctrlsf()


function setup_startify ()
  vim.g.startify_session_persistence = 1
  vim.g.startify_session_delete_buffers = 1
  vim.g.startify_session_before_save = {
    'silent! NvimTreeClose',
    'let g:startify_tmp_tabpagenr = tabpagenr()',
    'let g:startify_tmp_winnr = winnr()',
    'echo "Cleaning up before saving.."',
    'silent! tabdo NvimTreeClose',
    'execute "normal! " . g:startify_tmp_tabpagenr . "gt"',
    'execute g:startify_tmp_winnr . "wincmd w"'
  }
  vim.cmd[[
    augroup startify_stuff
        autocmd VimEnter * call init_startify()
        autocmd BufEnter * let &titlestring=fnamemodify(v:this_session, ':t')
    augroup END
  ]]
  vim.g.init_startify = function ()
    if not vim.fn.argc() then
      vim.cmd[[
        Startify
        NvimTreeOpen
        sleep 100m
        wincmd w
      ]]
    end
  end
end
setup_startify()


-- Set up indentline
function setup_indentline ()
  vim.g.indentLine_setColors = 1
  vim.g.indentLine_defaultGroup = "LineNr"
  vim.g.indentLine_char_list = {'¦'}
  vim.g.indentLine_concealcursor = 'c'
  -- Latex conceal compatibility
  vim.g.indentLine_fileTypeExclude = {'tex'}
end
setup_indentline()


-- Set up vim-cpp-enhanced-highlight
function setup_cpp_enhanced_highlight ()
  vim.g.cpp_class_scope_highlight = 1
  vim.g.cpp_member_variable_highlight = 1
  vim.g.cpp_class_decl_highlight = 1
  vim.g.cpp_posix_standard = 1
  vim.g.cpp_experimental_simple_template_highlight = 1
  vim.g.cpp_concepts_highlight = 1
end
setup_cpp_enhanced_highlight()


return ret
