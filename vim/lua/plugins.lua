local plugins = {}

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
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
  use {
    'mattn/emmet-vim',
    setup = function() vim.g.user_emmet_leader_key = '<C-x>' end
  }

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
      vim.cmd.colorscheme 'onehalflight'
      -- Hide (~) at the end of buffer
      vim.cmd.highlight 'NonText guifg=bg'
      vim.cmd.highlight 'EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg'
    end
  }
  use 'itchyny/lightline.vim'
  use 'voldikss/vim-floaterm'
  use 'tomtom/tcomment_vim'

  -- Better move
  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'
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
  use { 'octol/vim-cpp-enhanced-highlight', ft = { 'cpp', 'c' } }
  -- Python utils // The indent really saved my life
  use { 'Vimjas/vim-python-pep8-indent', ft = { 'python', } }
  use { 'jmcantrell/vim-virtualenv', ft = { 'python', } }
  -- Font-end tool chain
  use { 'ap/vim-css-color', ft = { 'css', 'less', 'scss', 'tsx', 'ts', 'vim', 'tmux', } }
  use { 'maxmellon/vim-jsx-pretty', ft = { 'tsx', 'jsx', } }
  use 'HerringtonDarkholme/yats.vim'
  use 'posva/vim-vue'
  -- Html preview
  use { 'turbio/bracey.vim', ft = { 'html', } }
  -- Markdown syntax and preview
  use 'godlygeek/tabular'
  use 'plasticboy/vim-markdown'
  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
    ft = { 'markdown', 'vim-plug', }
  }
  -- Asm
  use { 'Shirk/vim-gas', ft = 'asm' }
  use { 'cespare/vim-toml', ft = { 'toml', } }
  -- Latex
  use 'lervag/vimtex'

  -- Other utilities
  use 'mhinz/vim-rfc'
  use 'editorconfig/editorconfig-vim'
  use 'vim-scripts/Drawit'
  use 'voldikss/vim-translator'
  use {
    'puremourning/vimspector',
    setup = function() vim.g.vimspector_enable_mappings = 'HUMAN' end
  }
  use 'jceb/vim-orgmode'
  use 'itchyny/calendar.vim'
  use 'lilydjwg/fcitx.vim'

  if packer_bootstrap then
    require('packer').install()
  end
end)


-- Set up lspconfig.
plugins.setup_lspconfig = function()
  local lspconfig = require 'lspconfig'

  -- Mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', '<leader>o', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
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
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  end

  local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
  }
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  local language_servers = {
    'pyright', 'svls', 'clangd', 'tsserver', 'rust_analyzer', 'jsonls',
    'sumneko_lua', 'vimls',
  }

  for _, server in ipairs(language_servers) do
    lspconfig[server].setup {
      on_attach = on_attach,
      flags = lsp_flags,
      capabilities = capabilities,
    }
  end

  lspconfig.sumneko_lua.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        }
      }
    },
  }
end
plugins.setup_lspconfig()


-- Set up nvim-cmp
plugins.setup_cmp = function()
  local cmp = require 'cmp'

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
end
plugins.setup_cmp()


-- Set up tagbar
plugins.setup_tagbar = function()
  vim.g.tagbar_left = 1
  vim.g.tagbar_width = 32
  vim.g.tagbar_compact = 1
  vim.g.tagbar_sort = 0
  vim.g.typescript_use_builtin_tagbar_defs = 0
  vim.g.tagbar_type_cpp = {
    kinds      = {
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
plugins.setup_tagbar()


-- Set up lightline
plugins.setup_lightline = function()
  vim.g.lightline = {
    colorscheme = 'solarized',
    background = 'dark',
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

  vim.g.EmojiedFugitiveHead = function()
    return ' ' .. vim.fn.FugitiveHead()
  end
end
plugins.setup_lightline()


-- Set up gitgutter
plugins.setup_gitgutter = function()
  vim.g.gitgutter_enabled = 0
  -- <leader>h is used to switch split, while <leader>h* is used in gitgutter,
  -- which leads to unacceptable delay when pressing <leader>h, thus gitggutter key
  -- mappings are disabled and re-mapped.
  vim.g.gitgutter_map_keys = 0
  vim.keymap.set('n', '<leader>gg', ':GitGutterToggle<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', ']c', ':GitGutterNextHunk<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '[c', ':GitGutterPrevHunk<CR>', { noremap = true, silent = true })
end
plugins.setup_gitgutter()


-- Set up floaterm
plugins.setup_floaterm = function()
  if vim.fn.has('unix') or vim.fn.has('macunix') then
    vim.g.floaterm_shell = '/usr/bin/zsh'
  elseif vim.fn.has('win32') then
    vim.g.floaterm_shell = [[C:\Program Files\PowerShell\7\pwsh.exe]]
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
plugins.setup_floaterm()


-- Set up nvim-tree.lua
plugins.setup_nvim_tree = function()
  local mappings = {
    list = {
      { key = "K", action = "toggle_file_info" },
      { key = "t", action = "tabnew" },
      { key = "<C-k>", action = "" },
      { key = "<C-e>", action = "" },
    },
  }
  require("nvim-tree").setup({
    hijack_netrw = false,
    open_on_setup = false,
    open_on_setup_file = false,
    view = {
      side = "right",
      mappings = mappings,
      number = true,
      relativenumber = true,
      signcolumn = "yes",
      preserve_window_proportions = true,
    },
    respect_buf_cwd = true,
    actions = {
      open_file = {
        resize_window = false,
      },
    },
  })
  vim.cmd [[nnoremap <silent> <leader>e :NvimTreeToggle<CR>]]
  vim.cmd [[
  augroup explorer
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * call handle_open_directory()
  augroup END
  ]]
  vim.g.handle_open_directory = function()
    vim.cmd [[
    if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") 
      exe "cd" fnameescape(argv()[0])
      ene
      NvimTreeOpen
      sleep 100m
      wincmd w
    endif
    ]]
  end
end
plugins.setup_nvim_tree()


-- Set up vim-easymotion
plugins.setup_easymotion = function()
  vim.keymap.set('n', '<leader>S', '<Plug>(easymotion-s)', { silent = true })
  vim.keymap.set('n', '<leader>W', '<Plug>(easymotion-w)', { silent = true })
  vim.keymap.set('n', '<leader>S', '<Plug>(easymotion-s)', { silent = true })
  vim.keymap.set('n', '<leader>J', '<Plug>(easymotion-j)', { silent = true })
  vim.keymap.set('n', '<leader>K', '<Plug>(easymotion-k)', { silent = true })
end
plugins.setup_easymotion()


-- Set up fzf
plugins.setup_fzf = function()
  vim.keymap.set('n', 'F', ':FZF<CR>', { noremap = true, silent = true })
  vim.g.fzf_colors = {
    fg = { 'fg', 'Normal' },
    bg = { 'bg', 'Normal' },
    hl = { 'fg', 'Comment' },
    ['fg+'] = { 'fg', 'Cursor', 'CursorColumn', 'Normal' },
    ['bg+'] = { 'bg', 'Cursor', 'CursorColumn' },
    ['hl+'] = { 'fg', 'Statement' },
    info = { 'fg', 'PreProc' },
    border = { 'fg', 'Ignore' },
    prompt = { 'fg', 'Conditional' },
    pointer = { 'fg', 'Cursor' },
    marker = { 'fg', 'Keyword' },
    spinner = { 'fg', 'Label' },
    header = { 'fg', 'Comment' },
  }
end
plugins.setup_fzf()


-- Set up ctrlsf
plugins.setup_ctrlsf = function()
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
plugins.setup_ctrlsf()


plugins.setup_startify = function()
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
  vim.cmd [[
  augroup startify_stuff
    autocmd VimEnter * call init_startify()
    autocmd BufEnter * let &titlestring=fnamemodify(v:this_session, ':t')
  augroup END
  ]]
  vim.g.init_startify = function()
    if not vim.fn.argc() then
      vim.cmd [[
      Startify
      NvimTreeOpen
      sleep 100m
      wincmd w
      ]]
    end
  end
end
plugins.setup_startify()


-- Set up indentline
plugins.setup_indentline = function()
  vim.g.indentLine_setColors = 1
  vim.g.indentLine_defaultGroup = "LineNr"
  vim.g.indentLine_char_list = { '¦' }
  vim.g.indentLine_concealcursor = 'c'
  -- Latex conceal compatibility
  vim.g.indentLine_fileTypeExclude = { 'tex' }
end
plugins.setup_indentline()


-- Set up vim-cpp-enhanced-highlight
plugins.setup_cpp_enhanced_highlight = function()
  vim.g.cpp_class_scope_highlight = 1
  vim.g.cpp_member_variable_highlight = 1
  vim.g.cpp_class_decl_highlight = 1
  vim.g.cpp_posix_standard = 1
  vim.g.cpp_experimental_simple_template_highlight = 1
  vim.g.cpp_concepts_highlight = 1
end
plugins.setup_cpp_enhanced_highlight()


-- Set up bracey
plugins.setup_bracey = function()
  vim.g.bracey_server_port = 34911
  vim.g.bracey_server_allow_remote_connections = 1
  vim.g.bracey_refresh_on_save = 1
  vim.g.bracey_eval_on_save = 1
  vim.g.bracey_auto_start_server = 1
end
plugins.setup_bracey()


-- Set up vim-markdown
plugins.setup_vim_markdown = function()
  vim.g.vim_markdown_folding_level = 6
  vim.g.vim_markdown_conceal = 1
  vim.g.vim_markdown_conceal_code_blocks = 1
  vim.g.vim_markdown_autowrite = 1
  vim.g.vim_markdown_strikethrough = 1
  vim.g.vim_markdown_no_extensions_in_markdown = 1
  vim.cmd [[
  augroup md_config
    autocmd!
    autocmd VimEnter * let g:vim_markdown_folding_disabled = &diff
  augroup END
  ]]
end
plugins.setup_vim_markdown()


-- Set up markdown-preview.nvim
plugins.setup_markdown_prev = function()
  vim.g.mkdp_port = '34910'
  vim.g.mkdp_refresh_slow = 1
  vim.g.mkdp_open_to_the_world = 1
  vim.g.mkdp_echo_preview_url = 1
  vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', { noremap = true })
  vim.keymap.set('n', '<leader>ms', ':MarkdownPreviewStop<CR>', { noremap = true })
end
plugins.setup_markdown_prev()


-- Set up vimtex
plugins.setup_vimtex = function()
  vim.g.vimtex_complete_enabled = 0
  vim.g.vimtex_syntax_conceal = {
    accents = 1,
    cites = 1,
    fancy = 1,
    greek = 1,
    math_bounds = 1,
    math_delimiters = 1,
    math_fracs = 0,
    math_super_sub = 0,
    math_symbols = 1,
    styles = 1,
  }
  vim.g.vimtex_compiler_method = 'tectonic'
  vim.g.vimtex_compiler_tectonic = {
    build_dir = 'dist',
    options = { '--keep-logs', '--synctex', },
  }
  vim.g.vimtex_view_method = 'general'
  vim.g.vimtex_view_general_viewer = 'SumatraPDF'
  vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
  -- Inhibit unnecessary font warnings
  vim.g.vimtex_quickfix_ignore_filters = { [[.*Script "CJK".*]], }
  vim.keymap.set('n', '<localleader>lb',
    ':VimtexCompile<CR>', { noremap = true, silent = true })
  vim.cmd [[
  augroup vimtex_common
    autocmd!
    autocmd FileType tex call SetServerName()
  augroup END
  ]]
end
plugins.setup_vimtex()


-- Set up editorconfig
plugins.setup_editorconfig = function()
  vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*', 'scp://.*' }
  vim.cmd 'au FileType gitcommit let b:EditorConfig_disable = 1'
end
plugins.setup_editorconfig()


-- Set up vim-translator
plugins.setup_vim_translator = function()
  vim.keymap.set('n', '<leader>tr', ':Translate<CR>', { noremap = true, silent = true })
end
plugins.setup_vim_translator()


-- Set up fcitx.vim
plugins.setup_fcitx = function()
  vim.g.fcitx5_remote = '/usr/bin/fcitx5-remote'
  vim.g.fcitx5_rime = 1
end
plugins.setup_fcitx()


return plugins
