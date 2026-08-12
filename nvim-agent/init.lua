-- nvim-agent: minimal agent-cockpit config. Launch: NVIM_APPNAME=nvim-agent nvim
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

-- RPC socket at <launch cwd>/.agent/nvim.sock ------------------------------
local agent_dir = vim.fn.getcwd() .. '/.agent'
vim.fn.mkdir(agent_dir, 'p')
local sock = agent_dir .. '/nvim.sock'
local function start_server()
  local ok = pcall(vim.fn.serverstart, sock)
  if ok then return true end
  -- Address exists: stale socket or another live instance. Probe it.
  local probe_ok, ch = pcall(vim.fn.sockconnect, 'pipe', sock, { rpc = true })
  if probe_ok and ch and ch > 0 then
    vim.fn.chanclose(ch)
    vim.notify('nvim-agent: another instance owns ' .. sock, vim.log.levels.WARN)
    return false
  end
  pcall(vim.fn.delete, sock) -- stale: remove and retry
  return pcall(vim.fn.serverstart, sock)
end
vim.schedule(start_server)

-- Agent core (registry, bridge dispatch, recovery) -------------------------
require('agent').setup({})
