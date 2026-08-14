local M = {}

function M.open()
  local agent = require('agent-cockpit')
  local Snacks = require('snacks')
  local items = {}
  for _, w in ipairs(agent.list()) do
    items[#items + 1] = { text = w.id, worker = w }
  end
  Snacks.picker.pick({
    title = 'Agent Workers',
    items = items,
    format = function(item)
      local w = item.worker
      return { { ('%-10s %-10s %s %-9s %s'):format(
        w.id, w.cmd,
        w.alive and '●' or '○',
        w.visible and 'visible' or 'hidden',
        (w.state or 'unknown') .. (w.summary ~= '' and (' — ' .. w.summary:gsub('\n', ' ')) or '')
      ) } }
    end,
    -- Items carry no `file`, so give the previewer custom content:
    -- the worker's status file, falling back to its registry fields.
    preview = function(ctx)
      local w = ctx.item.worker
      local root = require('agent-cockpit')._root or vim.fn.getcwd()
      local status_path = root .. '/.agent/status/' .. w.id .. '.md'
      local lines = vim.fn.filereadable(status_path) == 1
        and vim.fn.readfile(status_path) or {}
      if #lines == 0 then
        lines = vim.split(vim.inspect(w), '\n', { plain = true })
      end
      vim.bo[ctx.buf].modifiable = true
      vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)
      vim.bo[ctx.buf].modifiable = false
    end,
    confirm = function(p, item)
      p:close()
      if item then agent.focus(item.worker.id) end
    end,
    actions = {
      hide_worker = function(p, item)
        p:close()
        if item then agent.hide(item.worker.id) end
      end,
      kill_worker = function(p, item)
        if not item then return end
        vim.ui.select({ 'yes', 'no' }, { prompt = 'Kill worker ' .. item.worker.id .. '?' },
          function(choice)
            p:close()
            if choice == 'yes' then agent.kill(item.worker.id) end
          end)
      end,
    },
    win = {
      input = { keys = {
        ['<M-h>'] = { 'hide_worker', mode = { 'n', 'i' } },
        ['<M-k>'] = { 'kill_worker', mode = { 'n', 'i' } },
      } },
      list = { keys = {
        ['<M-h>'] = 'hide_worker',
        ['<M-k>'] = 'kill_worker',
      } },
    },
  })
end

return M
