-- Three-zone layout engine.
-- Zones (left to right): [explorer?] [review area?] [agent area].
-- The explorer is owned by snacks; we only avoid mistaking its windows for
-- agent/content windows. The review area (file/dashboard faces) is one window
-- left of the agent area, hidden by default. The agent area holds worker
-- terminals:
--   Mode A: main (left 50%, full height) + team (right 50%): stacked rows
--           when <=3 members, auto-reflowing grid beyond (cols=ceil(sqrt(n))).
--   Mode B: main 50% + focused member 50% (a fixed slot; focusing another
--           member swaps the buffer, windows never rearrange).
-- Arrangement rebuilds the agent-area windows from scratch on every change:
-- windows are cheap and worker terminal buffers persist while hidden.
local M = {
  mode = 'A',
  _focused = nil,
  _review_win = nil,
  _face = nil,        -- 'file' | 'dashboard'
  _review_file = nil,
}

local function valid(win) return win and vim.api.nvim_win_is_valid(win) end
local function is_float(win) return vim.api.nvim_win_get_config(win).zindex ~= nil end

local function worker_id_of(win)
  local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
  if not ok then return nil end
  return vim.api.nvim_buf_get_name(buf):match('agent://worker/(.+)$')
end

local function is_snacks(win)
  local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
  return ok and vim.bo[buf].filetype:match('^snacks_') ~= nil
end

-- Agent windows left-to-right, top-to-bottom.
local function agent_wins()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_float(win) then
      local id = worker_id_of(win)
      if id then wins[#wins + 1] = { win = win, id = id } end
    end
  end
  table.sort(wins, function(a, b)
    local pa, pb = vim.api.nvim_win_get_position(a.win), vim.api.nvim_win_get_position(b.win)
    if pa[2] ~= pb[2] then return pa[2] < pb[2] end
    return pa[1] < pb[1]
  end)
  return wins
end

-- Worker ids that should be on screen, main first.
local function visible_ids()
  local reg = require('agent-cockpit.registry')
  local ids = {}
  if M.mode == 'B' then
    if reg.get('main') then ids[#ids + 1] = 'main' end
    if M._focused and M._focused ~= 'main' and reg.get(M._focused) then
      ids[#ids + 1] = M._focused
    end
    return ids
  end
  for _, e in ipairs(reg.list()) do
    if not e.hidden then ids[#ids + 1] = e.id end
  end
  return ids
end

local function scratch_buf()
  local b = vim.api.nvim_create_buf(false, true)
  vim.bo[b].bufhidden = 'wipe'
  return b
end

-- A window that survives the rebuild: review win > any non-agent,
-- non-snacks window > first agent window.
local function pick_survivor()
  if valid(M._review_win) then return M._review_win end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_float(win) and not worker_id_of(win) and not is_snacks(win) then
      return win
    end
  end
  local aws = agent_wins()
  return aws[1] and aws[1].win or nil
end

function M.arrange()
  local reg = require('agent-cockpit.registry')
  local ids = visible_ids()
  local survivor = pick_survivor()
  for _, w in ipairs(agent_wins()) do
    if w.win ~= survivor and vim.api.nvim_win_is_valid(w.win) then
      pcall(vim.api.nvim_win_close, w.win, true)
    end
  end
  if #ids == 0 then
    if survivor and worker_id_of(survivor) then
      vim.api.nvim_win_set_buf(survivor, scratch_buf())
    end
    return
  end

  -- Main window: reuse an agent survivor, absorb an empty content window
  -- (the agent area covers the whole panel when no real file/review area is
  -- open), else split right of the content. "Empty" = no name and no content,
  -- buftype-agnostic (leftover nofile scratch buffers count too).
  local function absorbable(win)
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf) ~= '' then return false end
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    return #lines <= 1 and (lines[1] or '') == ''
  end
  local main_win
  if survivor and worker_id_of(survivor) then
    main_win = survivor
  elseif survivor and absorbable(survivor) then
    main_win = survivor
  else
    vim.api.nvim_set_current_win(survivor)
    vim.cmd('botright vsplit')
    main_win = vim.api.nvim_get_current_win()
  end
  local main_id = reg.get('main') and 'main' or ids[1]
  vim.api.nvim_win_set_buf(main_win, reg.get(main_id).buf)

  local team = {}
  for _, id in ipairs(ids) do
    if id ~= main_id then team[#team + 1] = id end
  end

  -- Build the team area right of main.
  local n = #team
  if n > 0 then
    local cols = n <= 3 and 1 or math.ceil(math.sqrt(n))
    local rows = math.ceil(n / cols)
    local colwins = {}
    local anchor = main_win
    for c = 1, cols do
      vim.api.nvim_set_current_win(anchor)
      vim.cmd('rightbelow vsplit')
      local cw = vim.api.nvim_get_current_win()
      colwins[c] = { cw }
      for _ = 2, rows do
        vim.api.nvim_set_current_win(colwins[c][#colwins[c]])
        vim.cmd('rightbelow split')
        colwins[c][#colwins[c] + 1] = vim.api.nvim_get_current_win()
      end
      anchor = cw
    end
    -- Column-major fill: member i -> col i//rows, row i%rows.
    for i, id in ipairs(team) do
      local c = math.floor((i - 1) / rows) + 1
      local r = (i - 1) % rows + 1
      vim.api.nvim_win_set_buf(colwins[c][r], reg.get(id).buf)
    end
  end

  -- Sizes: main = 50% of the agent area; team columns share the rest;
  -- rows share their column's height.
  local left_w = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_float(win) and not worker_id_of(win) then
      left_w = left_w + vim.api.nvim_win_get_width(win) + 1 -- +separator
    end
  end
  local agent_w = vim.o.columns - left_w
  local main_w = math.floor(agent_w / 2)
  vim.api.nvim_win_set_width(main_win, main_w)
  if n > 0 then
    local cols = n <= 3 and 1 or math.ceil(math.sqrt(n))
    local rows = math.ceil(n / cols)
    local team_w = math.floor((agent_w - main_w - cols) / cols)
    local h = vim.api.nvim_win_get_height(main_win)
    local row_h = math.floor(h / rows)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local id = not is_float(win) and worker_id_of(win) or nil
      if id and id ~= main_id then
        pcall(vim.api.nvim_win_set_width, win, team_w)
        pcall(vim.api.nvim_win_set_height, win, row_h)
      end
    end
  end
end

function M.set_mode(mode)
  assert(mode == 'A' or mode == 'B', 'mode must be A or B')
  M.mode = mode
  if mode == 'B' and not M._focused then
    local reg = require('agent-cockpit.registry')
    for _, e in ipairs(reg.list()) do
      if e.id ~= 'main' and not e.hidden then M._focused = e.id break end
    end
  end
  M.arrange()
end

function M.toggle_mode()
  M.set_mode(M.mode == 'A' and 'B' or 'A')
end

function M.focus(id)
  local reg = require('agent-cockpit.registry')
  local e = reg.get(id)
  if not e then return nil, 'unknown worker: ' .. tostring(id) end
  e.hidden = false
  if id == 'main' then
    M.mode = 'B'
    M._focused = nil
    M.arrange()
    for _, w in ipairs(agent_wins()) do
      if w.id == 'main' then vim.api.nvim_set_current_win(w.win) end
    end
    return true
  end
  M._focused = id
  M.mode = 'B'
  M.arrange()
  for _, w in ipairs(agent_wins()) do
    if w.id == id then vim.api.nvim_set_current_win(w.win) end
  end
  return true
end

function M.jump(id)
  for _, w in ipairs(agent_wins()) do
    if w.id == id then
      vim.api.nvim_set_current_win(w.win)
      return true
    end
  end
  return M.focus(id)
end

function M.hide(id)
  local reg = require('agent-cockpit.registry')
  local e = reg.get(id)
  if not e then return nil, 'unknown worker: ' .. tostring(id) end
  e.hidden = true
  if M._focused == id then M._focused = nil end
  if M.mode == 'B' and not M._focused then M.mode = 'A' end
  M.arrange()
  return true
end

function M.is_visible(id)
  for _, w in ipairs(agent_wins()) do
    if w.id == id then return true end
  end
  return false
end

-- Task 3 replaces this shim with the full review-area implementation.
function M.open_main(path)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_float(win) and not worker_id_of(win) and not is_snacks(win) then
      vim.api.nvim_set_current_win(win)
      vim.cmd.edit(vim.fn.fnameescape(path))
      return
    end
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
end

function M.setup(_) end

return M
