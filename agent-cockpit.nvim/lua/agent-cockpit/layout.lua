local M = {}

local function valid(win) return win and vim.api.nvim_win_is_valid(win) end

local function is_float(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

function M.main_win()
  if valid(M._main_win) then return M._main_win end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_float(win) and not vim.w[win].agent_worker_pane then
      M._main_win = win
      return win
    end
  end
  return vim.api.nvim_get_current_win()
end

function M.worker_pane()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if valid(win) and vim.w[win].agent_worker_pane then return win end
  end
  vim.cmd('botright vsplit')
  local win = vim.api.nvim_get_current_win()
  vim.w[win].agent_worker_pane = true
  vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.4))
  return win
end

function M.show(buf)
  local win = M.worker_pane()
  vim.api.nvim_win_set_buf(win, buf)
end

function M.hide(buf)
  local cur = vim.api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if vim.api.nvim_win_get_tabpage(win) == cur
      and #vim.api.nvim_tabpage_list_wins(0) > 1 then
      vim.api.nvim_win_close(win, true)
    end
  end
end

function M.open_main(path)
  vim.api.nvim_set_current_win(M.main_win())
  vim.cmd.edit(vim.fn.fnameescape(path))
  M._main_win = vim.api.nvim_get_current_win()
end

return M
