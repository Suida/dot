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
  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-dap',
    {
      'jose-elias-alvarez/null-ls.nvim',
      ft = { 'lua', 'python', },
    }
  }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
  use {
    "glepnir/lspsaga.nvim",
    opt = true,
    branch = "main",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({})
    end,
    requires = {
      {"nvim-tree/nvim-web-devicons"},
      --Please make sure you install markdown and markdown_inline parser
      {"nvim-treesitter/nvim-treesitter"}
    },
  }

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use({
    'hrsh7th/nvim-cmp',
    requires = {
      { 'jc-doyle/cmp-pandoc-references' }
    }
  })

  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  -- Code template
  use {
    'mattn/emmet-vim',
    setup = function() vim.g.user_emmet_leader_key = '<C-x>' end
  }

  -- Zettelkasten
  use 'mickael-menu/zk-nvim'

  -- Git
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'

  -- Outlook
  use {
    'folke/tokyonight.nvim',
    config = function ()
      vim.cmd.colorscheme 'tokyonight-storm'
    end
  }
  use {
    'nvim-lualine/lualine.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
  }
  use 'voldikss/vim-floaterm'
  use 'willothy/flatten.nvim'
  use 'tomtom/tcomment_vim'
  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- Better move
  use 'nvim-tree/nvim-web-devicons'
  use 'nvim-tree/nvim-tree.lua'
  use 'easymotion/vim-easymotion'
  use 'andymass/vim-matchup'
  use 'tpope/vim-surround'
  -- Brackets
  use 'jiangmiao/auto-pairs'
  use 'tpope/vim-unimpaired'
  -- Marker
  use 'kshenoy/vim-signature'

  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  -- Global finder
  use 'brooth/far.vim'

  -- Session manager
  use 'mhinz/vim-startify'

  -- Indentation line
  use 'Yggdroot/indentLine'
  use 'tpope/vim-sleuth'


  -- Language supports
  -- Python utils // The indent really saved my life
  use { 'Vimjas/vim-python-pep8-indent', ft = { 'python', } }
  use { 'jmcantrell/vim-virtualenv', ft = { 'python', } }
  -- Font-end tool chain
  use { 'ap/vim-css-color', ft = { 'css', 'less', 'scss', 'tsx', 'ts', 'vim', 'tmux', } }
  use { 'maxmellon/vim-jsx-pretty', ft = { 'tsx', 'jsx', } }
  use 'HerringtonDarkholme/yats.vim'
  use 'posva/vim-vue'
  -- Pandoc
  use 'vim-pandoc/vim-pandoc'
  use 'vim-pandoc/vim-pandoc-syntax'
  -- Html preview
  use { 'turbio/bracey.vim', ft = { 'html', } }
  -- Markdown syntax and preview
  use 'godlygeek/tabular'
  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
    ft = { 'markdown', 'vim-plug', }
  }
  -- Asm
  use { 'Shirk/vim-gas', ft = 'asm' }
  use { 'cespare/vim-toml', ft = { 'toml', } }

  -- Other utilities
  use 'mhinz/vim-rfc'
  use 'editorconfig/editorconfig-vim'
  use 'vim-scripts/Drawit'
  use 'voldikss/vim-translator'
  use 'jceb/vim-orgmode'
  use 'itchyny/calendar.vim'
  use 'lilydjwg/fcitx.vim'

  if packer_bootstrap then
    require('packer').install()
  end
end)

