-- RPC socket bootstrap + bridge environment injection.
-- Unix listens on a socket file at <root>/.agent/nvim.sock. Windows cannot, so
-- it listens on a named pipe derived from the root and writes the pipe name
-- into .agent/nvim.sock as a plain-text pointer file for clients to discover.
local M = {}

function M.ensure(root)
  local is_windows = vim.fn.has('win32') == 1
  local agent_dir = root .. '/.agent'
  vim.fn.mkdir(agent_dir, 'p')
  local sock = agent_dir .. '/nvim.sock'
  local addr = is_windows
      and ('\\\\.\\pipe\\nvim-agent-' .. vim.fn.sha256(root):sub(1, 16))
      or sock
  local function on_started()
    if is_windows then
      local wok = pcall(vim.fn.writefile, { addr }, sock, 'b') -- pointer file (no trailing NL)
      if not wok then
        vim.notify('agent-cockpit: failed to write pointer file ' .. sock, vim.log.levels.WARN)
      end
    end
    vim.env.NVIM_AGENT_SOCK = addr -- terminal jobs (agents) inherit this
    return true
  end
  local function start()
    if pcall(vim.fn.serverstart, addr) then return on_started() end
    -- Address exists: stale socket or another live instance. Probe it.
    local probe_ok, ch = pcall(vim.fn.sockconnect, 'pipe', addr, { rpc = true })
    if probe_ok and ch and ch > 0 then
      vim.fn.chanclose(ch)
      vim.notify('agent-cockpit: another instance owns ' .. addr, vim.log.levels.WARN)
      return false
    end
    if not is_windows then pcall(vim.fn.delete, sock) end
    if pcall(vim.fn.serverstart, addr) then return on_started() end
    vim.notify('agent-cockpit: failed to start RPC server at ' .. addr, vim.log.levels.WARN)
    return false
  end
  vim.schedule(start)

  -- Put agent-ctl on PATH for everything spawned from this instance (worker
  -- agent CLIs inherit nvim's environment). socket.lua is at
  -- lua/agent-cockpit/, so the plugin root is three dirs up from this file.
  local src = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
  local plugin_root = vim.fn.fnamemodify(src, ':h:h:h')
  vim.env.PATH = plugin_root .. '/bin' .. (is_windows and ';' or ':') .. vim.env.PATH
end

return M
