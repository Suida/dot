local utils = require 'user.utils'


-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- Set python and node providers
if utils.get_os_type() == 'unix' then
  vim.g.python3_host_prog = '~/.local/share/pynvim-env/.venv/bin/python'
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
require 'plugin_conf.none-ls'
require 'plugin_conf.dap'
require 'plugin_conf.treesitter'
require 'plugin_conf.cmp-conf'
require 'plugin_conf.telekasten'
require 'plugin_conf.gitsigns'
require 'plugin_conf.overseer'
require 'plugin_conf.lualine'
require 'plugin_conf.toggleterm'
require 'plugin_conf.hop_conf'
require 'plugin_conf.telescope'
require 'plugin_conf.indentline'
require 'plugin_conf.bracey'
require 'plugin_conf.markdown-preview'
require 'plugin_conf.editorconfig'
require 'plugin_conf.translator'
require 'plugin_conf.fcitx'
require 'plugin_conf.diagnostic'
require 'plugin_conf.copilot'
require 'plugin_conf.codecompanion_ds'
require 'plugin_conf.snacks-conf'
require 'ftdetect'

require('user.autocolor').setup()


vim.cmd [[autocmd FileType scss setl iskeyword+=@-@]]


-- Configure the statusline. Although snacks has done this job, this is reserved for future changes.
vim.opt.fillchars:append({
  eob = " ",
  foldsep = " ",
  foldopen = "",
  foldclose = "",
})
vim.opt.foldlevel = 1
-- Set GUI options
vim.opt.guifont = "CaskaydiaCove Nerd Font:h10"
vim.opt.linespace = 4

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.2
end


-- Indentation
vim.cmd [[
augroup indent
  autocmd FileType javascript,css,less,vue,html,typescript,javascriptreact,typescriptreact set shiftwidth=2
  autocmd FileType systemverilog,verilog set shiftwidth=4 tabstop=4
augroup END
]]


-- File type certain settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "typst", "markdown" },
  callback = function(_)
    vim.opt_local.wrap = true
  end,
})
