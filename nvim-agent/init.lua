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

-- RPC socket at <launch cwd>/.agent/nvim.sock ------------------------------
-- Unix listens on a socket file at that path. Windows cannot, so it listens on
-- a named pipe derived from the cwd and writes the pipe name into
-- .agent/nvim.sock as a plain-text pointer file for clients to discover.
local is_windows = vim.fn.has('win32') == 1
local agent_dir = vim.fn.getcwd() .. '/.agent'
vim.fn.mkdir(agent_dir, 'p')
local sock = agent_dir .. '/nvim.sock'
local addr = is_windows
    and ('\\\\.\\pipe\\nvim-agent-' .. vim.fn.sha256(vim.fn.getcwd()):sub(1, 16))
    or sock
local function start_server()
  local function on_started()
    if is_windows then
      local wok = pcall(vim.fn.writefile, { addr }, sock, 'b') -- pointer file (no trailing NL)
      if not wok then
        vim.notify('nvim-agent: failed to write pointer file ' .. sock, vim.log.levels.WARN)
      end
    end
    vim.env.NVIM_AGENT_SOCK = addr -- terminal jobs (agents) inherit this
    return true
  end
  local ok = pcall(vim.fn.serverstart, addr)
  if ok then return on_started() end
  -- Address exists: stale socket or another live instance. Probe it.
  local probe_ok, ch = pcall(vim.fn.sockconnect, 'pipe', addr, { rpc = true })
  if probe_ok and ch and ch > 0 then
    vim.fn.chanclose(ch)
    vim.notify('nvim-agent: another instance owns ' .. addr, vim.log.levels.WARN)
    return false
  end
  if not is_windows then
    pcall(vim.fn.delete, sock) -- stale socket file: remove and retry
  end
  -- Dead address (a dead Windows pipe name is reusable): retry once.
  if pcall(vim.fn.serverstart, addr) then return on_started() end
  vim.notify('nvim-agent: failed to start RPC server at ' .. addr, vim.log.levels.WARN)
  return false
end
vim.schedule(start_server)

-- Put agent-ctl on PATH for everything spawned from this instance (worker
-- agent CLIs inherit nvim's environment), so the bridge works regardless of
-- the user's shell PATH setup.
local cfg_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
vim.env.PATH = cfg_dir .. '/bin' .. (is_windows and ';' or ':') .. vim.env.PATH

-- Agent core (registry, bridge dispatch, recovery) -------------------------
require('agent').setup({})
