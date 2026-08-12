local M = {}

local function root()
  local ok, agent = pcall(require, 'agent')
  return (ok and agent._root) or vim.fn.getcwd()
end

local function path() return root() .. '/.agent/session.json' end

function M.save()
  local agent = require('agent')
  local reg = require('agent.registry')
  local layout = require('agent.layout')
  local main_file
  local win = layout.main_win()
  if win and vim.api.nvim_win_is_valid(win) then
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' then main_file = name end
    end
  end
  local data = {
    version = 1,
    clean_exit = false,
    workers = reg.serialize(),
    main_file = main_file,
    foreground = agent._foreground,
  }
  local tmp = path() .. '.tmp'
  local f = io.open(tmp, 'w')
  if not f then
    vim.notify('nvim-agent: failed to write ' .. tmp, vim.log.levels.WARN)
    return
  end
  f:write(vim.json.encode(data))
  f:close()
  if not vim.uv.fs_rename(tmp, path()) then
    vim.notify('nvim-agent: failed to rename ' .. tmp .. ' -> ' .. path(), vim.log.levels.WARN)
  end
end

function M.load()
  local f = io.open(path(), 'r')
  if not f then return nil end
  local body = f:read('a')
  f:close()
  local ok, data = pcall(vim.json.decode, body)
  if not ok or type(data) ~= 'table' then
    vim.notify('nvim-agent: corrupt session.json, starting cold', vim.log.levels.WARN)
    return nil
  end
  return data
end

function M.mark_clean_exit()
  local data = M.load()
  if not data then return end
  data.clean_exit = true
  local tmp = path() .. '.tmp'
  local f = io.open(tmp, 'w')
  if not f then
    vim.notify('nvim-agent: failed to write ' .. tmp, vim.log.levels.WARN)
    return
  end
  f:write(vim.json.encode(data))
  f:close()
  if not vim.uv.fs_rename(tmp, path()) then
    vim.notify('nvim-agent: failed to rename ' .. tmp .. ' -> ' .. path(), vim.log.levels.WARN)
  end
end

return M
