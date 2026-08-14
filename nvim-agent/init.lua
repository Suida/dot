-- nvim-agent: minimal agent-cockpit profile. Launch: NVIM_APPNAME=nvim-agent nvim
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.termguicolors = true

-- Windows: when nvim is launched from Git Bash, SHELL leaks into 'shell' while
-- 'shellcmdflag' stays at the cmd.exe default (/s /c). String-form termopen
-- then fails to launch, and a failed terminal launch can crash nvim once the
-- terminal buffer has been shown in a window. Reset to the standard Windows
-- shell so worker spawns work from Git Bash.
if vim.fn.has('win32') == 1 and vim.o.shellcmdflag == '/s /c'
  and vim.o.shell:lower():match('[\\/][a-z]*sh%.exe') then
  vim.o.shell = 'cmd.exe'
end

-- lazy.nvim bootstrap ------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup('plugins')
