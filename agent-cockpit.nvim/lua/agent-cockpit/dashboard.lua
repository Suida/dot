-- Mission-control dashboard: one buffer listing all members with live state,
-- shown as the 'dashboard' face of the review area. Refresh is driven by an
-- fs_event watcher on .agent/status/ plus explicit renders on registry
-- mutations — no polling.
local M = { _buf = nil, _watcher = nil, _states = {}, _rows = {} }

function M.render()
  if not (M._buf and vim.api.nvim_buf_is_valid(M._buf)) then return end
  local agent = require('agent-cockpit')
  local lines = {
    ('%-12s %-10s %-5s %-9s %s'):format('ROLE', 'CLI', 'ALIVE', 'STATE', 'SUMMARY'),
    string.rep('-', 60),
  }
  M._rows = {}
  for _, w in ipairs(agent.list()) do
    M._rows[#M._rows + 1] = w.id
    local summary = (w.summary or ''):gsub('\n', ' ')
    lines[#lines + 1] = ('%-12s %-10s %-5s %-9s %s'):format(
      w.role or w.id,
      (w.cmd or ''):match('^%S+'),
      w.alive and '●' or '○',
      w.state or 'unknown',
      summary:sub(1, 40))
  end
  vim.bo[M._buf].modifiable = true
  vim.api.nvim_buf_set_lines(M._buf, 0, -1, false, lines)
  vim.bo[M._buf].modifiable = false
end

--- Map a 1-based buffer line to a member id (line 1 = header, 2 = rule).
function M._row_id(lnum) return M._rows[lnum - 2] end

function M.buf()
  if M._buf and vim.api.nvim_buf_is_valid(M._buf) then return M._buf end
  local b = vim.api.nvim_create_buf(false, true)
  pcall(vim.api.nvim_buf_set_name, b, 'agent://dashboard')
  vim.bo[b].bufhidden = 'hide'
  M._buf = b
  M.render()
  vim.keymap.set('n', '<CR>', function()
    local id = M._row_id(vim.api.nvim_win_get_cursor(0)[1])
    if id then require('agent-cockpit').jump(id) end
  end, { buffer = b, desc = 'Focus member' })
  return b
end

function M.open()
  require('agent-cockpit.zones').show_in_review(M.buf(), 'dashboard')
  M.render()
end

function M.toggle()
  local zones = require('agent-cockpit.zones')
  local st = zones.review_state()
  if st.open and st.face == 'dashboard' then
    zones.close_review()
  else
    M.open()
  end
end

--- Recompute member states; on transition to blocked/done notify.
--- Re-renders when the dashboard is on screen.
function M._check(_root)
  local agent = require('agent-cockpit')
  local changed = false
  for _, w in ipairs(agent.list()) do
    local prev = M._states[w.id]
    if prev ~= w.state then
      M._states[w.id] = w.state
      changed = true
      if prev ~= nil and (w.state == 'blocked' or w.state == 'done') then
        local first = (w.summary or ''):match('[^\n]+') or ''
        vim.notify(('agent %s -> %s%s'):format(
          w.id, w.state, first ~= '' and (': ' .. first) or ''),
          w.state == 'blocked' and vim.log.levels.WARN or vim.log.levels.INFO)
      end
    end
  end
  local zones = require('agent-cockpit.zones')
  local st = zones.review_state()
  if changed and st.open and st.face == 'dashboard' then M.render() end
end

--- Start the fs_event watcher on <root>/.agent/status/. Idempotent.
function M.watch(root)
  if M._watcher then return end
  local dir = root .. '/.agent/status'
  vim.fn.mkdir(dir, 'p')
  local h = vim.uv.new_fs_event()
  M._watcher = h
  h:start(dir, {}, vim.schedule_wrap(function()
    M._check(root)
  end))
end

return M
