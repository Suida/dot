local utils = require 'user.utils'


-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- Set python and node providers
if utils.get_os_type() == 'unix' then
  vim.g.python3_host_prog = '~/.pyenv/versions/nvim/bin/python'
else
  if os.getenv('PYENV_ROOT') ~= nil then
    vim.g.python3_host_prog = utils.append_slash(os.getenv('PYENV_ROOT')) .. [[versions\nvim\Scripts\python.exe]]
  end
end


-- Exit terminal mode
vim.keymap.set({ 't', 'i' }, 'jk', [[<C-\><C-n>]], { noremap = true })


-- Load vim config files
local vim_script_dir = utils.append_slash(vim.fn.stdpath('config')) .. 'vim_scripts/'
local vim_config_src = vim_script_dir .. 'config.vim'
local vim_mapping_src = vim_script_dir .. 'general_mappings.vim'
vim.cmd('source ' .. vim_config_src)
vim.cmd('source ' .. vim_mapping_src)


require 'plugin_conf.plugins'
require 'plugin_conf.mason'
require 'plugin_conf.lspconfig'
require 'plugin_conf.dap'
require 'plugin_conf.null-ls'
require 'plugin_conf.lspsaga'
require 'plugin_conf.treesitter'
require 'plugin_conf.cmp'
require 'plugin_conf.telekasten'
require 'plugin_conf.gitsigns'
require 'plugin_conf.overseer'
require 'plugin_conf.lualine'
require 'plugin_conf.toggleterm'
require 'plugin_conf.nvim-tree'
require 'plugin_conf.hop'
require 'plugin_conf.telescope'
require 'plugin_conf.startify'
require 'plugin_conf.indentline'
require 'plugin_conf.pandoc'
require 'plugin_conf.bracey'
require 'plugin_conf.markdown-preview'
require 'plugin_conf.editorconfig'
require 'plugin_conf.translator'
require 'plugin_conf.fcitx'
require 'plugin_conf.diagnostic'

require('user.autocolor').setup()


vim.cmd [[autocmd FileType scss setl iskeyword+=@-@]]


-- Indentation
vim.cmd [[
augroup indent
  autocmd FileType javascript,css,less,vue,html,typescript,javascriptreact,typescriptreact set shiftwidth=2
  autocmd FileType systemverilog,verilog set shiftwidth=4 tabstop=4
augroup END
]]


-- Folding behaviour of viml files
vim.cmd [[
augroup filtype_vim
  autocmd!
  autocmd FileType vim setlocal foldenable
  autocmd FileType vim setlocal foldlevel=0
  autocmd FileType vim setlocal foldmethod=marker
augroup END
]]
