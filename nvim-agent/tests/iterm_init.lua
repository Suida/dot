-- Integration-test init: socket + agent core, no lazy.nvim/plugins.
-- Resolve the nvim-agent dir from this script's path so tests can run from any cwd.
local src = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
local tests = vim.fn.fnamemodify(src, ':h')           -- nvim-agent/tests
-- Strip trailing separator: on Windows ':p' yields a trailing '\' which
-- breaks runtime-file lookup (nvim_get_runtime_file) for that entry.
local dir = vim.fn.fnamemodify(tests, ':h'):gsub('[\\/]$', '')  -- nvim-agent
vim.opt.rtp:prepend(dir)
-- With '-u <file>' the rtp lua loader (vim.loader) may not be enabled, so
-- require('agent.*') would not search the runtimepath without this.
if vim.loader then vim.loader.enable() end
-- Windows: when nvim is launched from Git Bash, SHELL leaks into 'shell' while
-- 'shellcmdflag' stays at the cmd.exe default (/s /c). String-form termopen
-- then fails to launch the worker. Emulate the standard Windows shell.
if vim.fn.has('win32') == 1 and vim.o.shellcmdflag == '/s /c'
  and vim.o.shell:lower():match('[\\/][a-z]*sh%.exe') then
  vim.o.shell = 'cmd.exe'
end

-- RPC socket at <launch cwd>/.agent/nvim.sock. Unix listens on a socket file
-- there; Windows cannot, so it listens on a named pipe derived from the cwd
-- and writes the pipe name into .agent/nvim.sock as a plain-text pointer file.
local is_windows = vim.fn.has('win32') == 1
local agent_dir = vim.fn.getcwd() .. '/.agent'
vim.fn.mkdir(agent_dir, 'p')
local sock = agent_dir .. '/nvim.sock'
local addr = is_windows
    and ('\\\\.\\pipe\\nvim-agent-' .. vim.fn.sha256(vim.fn.getcwd()):sub(1, 16))
    or sock
pcall(vim.fn.delete, sock) -- stale socket file / pointer file
local function start_server()
  local function on_started()
    if is_windows then
      pcall(vim.fn.writefile, { addr }, sock, 'b') -- pointer file (no trailing NL)
    end
    return true
  end
  if pcall(vim.fn.serverstart, addr) then return on_started() end
  if not is_windows then pcall(vim.fn.delete, sock) end
  -- Dead address (a dead Windows pipe name is reusable): retry once.
  if pcall(vim.fn.serverstart, addr) then return on_started() end
  vim.notify('nvim-agent: failed to start RPC server at ' .. addr, vim.log.levels.WARN)
  return false
end
vim.schedule(start_server)

require('agent').setup({ main_agent = false })
