local M = {}

local function root()
  local ok, agent = pcall(require, 'agent-cockpit')
  return (ok and agent._root) or vim.fn.getcwd()
end

local function path() return root() .. '/.agent/session.json' end

function M.save()
  local agent = require('agent-cockpit')
  local reg = require('agent-cockpit.registry')
  -- The "main file" is the first ordinary file buffer in a non-agent,
  -- non-snacks window (the review area or a plain editing window).
  local main_file
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).zindex == nil then
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      if vim.bo[buf].buftype == '' and name ~= ''
        and not name:match('agent://worker/')
        and not vim.bo[buf].filetype:match('^snacks_') then
        main_file = name
        break
      end
    end
  end
  local zones = require('agent-cockpit.zones')
  local has_team, team = pcall(require, 'agent-cockpit.team') -- optional module
  local data = {
    version = 1,
    clean_exit = false,
    workers = reg.serialize(),
    main_file = main_file,
    foreground = agent._foreground,
    layout_mode = zones.mode,
    focused = zones._focused,
    review = zones.review_state(),
    roster = has_team and team.has_roster(root()) or false,
  }
  local tmp = path() .. '.tmp'
  local f = io.open(tmp, 'w')
  if not f then
    vim.notify('agent-cockpit: failed to write ' .. tmp, vim.log.levels.WARN)
    return
  end
  f:write(vim.json.encode(data))
  f:close()
  if not vim.uv.fs_rename(tmp, path()) then
    vim.notify('agent-cockpit: failed to rename ' .. tmp .. ' -> ' .. path(), vim.log.levels.WARN)
  end
end

function M.load()
  local f = io.open(path(), 'r')
  if not f then return nil end
  local body = f:read('a')
  f:close()
  local ok, data = pcall(vim.json.decode, body)
  if not ok or type(data) ~= 'table' then
    vim.notify('agent-cockpit: corrupt session.json, starting cold', vim.log.levels.WARN)
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
    vim.notify('agent-cockpit: failed to write ' .. tmp, vim.log.levels.WARN)
    return
  end
  f:write(vim.json.encode(data))
  f:close()
  if not vim.uv.fs_rename(tmp, path()) then
    vim.notify('agent-cockpit: failed to rename ' .. tmp .. ' -> ' .. path(), vim.log.levels.WARN)
  end
end

return M
