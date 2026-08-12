local M = { workers = {}, order = {} }

function M.add(id, entry)
  assert(M.workers[id] == nil, 'duplicate worker id: ' .. id)
  M.workers[id] = entry
  M.order[#M.order + 1] = id
end

function M.get(id) return M.workers[id] end

function M.remove(id)
  M.workers[id] = nil
  for i, v in ipairs(M.order) do
    if v == id then table.remove(M.order, i) break end
  end
end

function M.alive(e)
  return type(e.job) == 'number' and e.job > 0
    and vim.fn.jobwait({ e.job }, 0)[1] == -1
end

function M.visible(e)
  if not (e.buf and vim.api.nvim_buf_is_valid(e.buf)) then return false end
  local cur = vim.api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.fn.win_findbuf(e.buf)) do
    if vim.api.nvim_win_get_tabpage(win) == cur then return true end
  end
  return false
end

function M.list()
  local out = {}
  for _, id in ipairs(M.order) do out[#out + 1] = M.workers[id] end
  return out
end

function M.by_index(n)
  local id = M.order[n]
  return id and M.workers[id] or nil
end

function M.serialize()
  local out = {}
  for _, e in ipairs(M.list()) do
    out[#out + 1] = {
      id = e.id, agent = e.agent, cmd = e.cmd, cwd = e.cwd,
      task_file = e.task_file, op_overrides = e.op_overrides or {},
      visible = M.visible(e),
    }
  end
  return out
end

return M
