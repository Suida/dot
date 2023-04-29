local utils = require 'user.utils'


-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "  "


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
vim.keymap.set({ 't', 'i' }, 'Jk', [[<C-\><C-n>]], { noremap = true })
vim.keymap.set({ 't', 'i' }, 'JK', [[<C-\><C-n>]], { noremap = true })
vim.keymap.set({ 't', 'i' }, 'jjk', [[<C-\><C-n>]], { noremap = true })


-- Load vim config files
local vim_script_dir = utils.append_slash(vim.fn.stdpath('config')) .. 'vim_scripts/'
local vim_config_src = vim_script_dir .. 'config.vim'
local vim_mapping_src = vim_script_dir .. 'general_mappings.vim'
vim.cmd('source ' .. vim_config_src)
vim.cmd('source ' .. vim_mapping_src)


require 'user.plugins'
require 'user.mason'
require 'user.lspconfig'
require 'user.dap'
require 'user.null-ls'
require 'user.lspsaga'
require 'user.treesitter'
require 'user.cmp'
require 'user.telekasten'
require 'user.gitsigns'
require 'user.lualine'
require 'user.floaterm'
require 'user.nvim-tree'
require 'user.easymotion'
require 'user.telescope'
require 'user.startify'
require 'user.indentline'
require 'user.pandoc'
require 'user.bracey'
require 'user.markdown-preview'
require 'user.editorconfig'
require 'user.translator'
require 'user.fcitx'
require 'user.diagnostic'


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

