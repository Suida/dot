local utils = require 'user.utils'

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
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      { "jc-doyle/cmp-pandoc-references" }
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
  use 'willothy/flatten.nvim'
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
  -- C/C++
  -- use { 'octol/vim-cpp-enhanced-highlight', disable = true, ft = { 'cpp', 'c' } }
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

return plugins
