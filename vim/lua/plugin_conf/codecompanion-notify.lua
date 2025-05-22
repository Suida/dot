local notifier_id = "llm_request_notifier"

local spinners = {
  dots = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  arrows = { "←", "↖", "↑", "↗", "→", "↘", "↓", "↙" },
  bars = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█", "█", "▇", "▆", "▅", "▄", "▃", "▂", "▁", }
}

local levels = {
  success = { lvl = "info", msg = "completed", icon = "" },
  error = { lvl = "error", msg = "failed", icon = "" },
  cancelled = { lvl = "info", msg = "cancelled", icon = "󰜺" }
}

local M = {
  spinner_index = 1,
  spinner_style = "bars",
  frame_time = 80,
  request_timer = nil,
  requesting = false,
}

function M.get_spinner()
  return spinners[M.spinner_style]
end

function M.update_spinner_index()
  M.spinner_index = M.spinner_index == #M.get_spinner() and 1 or M.spinner_index + 1
end

function M.requesting_worker(model_name)
  vim.notify("Requesting " .. model_name .. "...", "info", {
    id = notifier_id,
    title = "CodeCompanion",
    opts = function(notif)
      notif.icon = M.get_spinner()[M.spinner_index]
    end,
  })
  M.update_spinner_index()
  if M.requesting then
    M.request_timer = vim.defer_fn(function() M.requesting_worker(model_name) end, M.frame_time);
  end
end

function M.finish_request(model_name, status)
  if M.request_timer ~= nil then
    vim.loop.timer_stop(M.request_timer)
    M.request_timer = nil
  end

  local result = levels[status] or levels.cancelled

  vim.notify("Request to " .. model_name .. " " .. result.msg, result.lvl, {
    id = notifier_id,
    title = "CodeCompanion",
    opts = function(notif)
      notif.icon = result.icon
    end,
  })
end

function M.setup(opts)
  opts = opts or {}
  M.spinner_style = opts.spinner_style or M.spinner_style
  M.frame_time = opts.frame_time or M.frame_time

  local group = vim.api.nvim_create_augroup("llm_request_notify", { clear = true })

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "CodeCompanionRequest*",
    callback = function(req)
      local adapter = req.data.adapter
      local model_name = adapter.model

      if req.match == "CodeCompanionRequestStarted" then
        M.requesting = true
        M.requesting_worker(model_name)
      elseif req.match == "CodeCompanionRequestFinished" then
        M.requesting = false
        M.finish_request(model_name, req.data.status)
      end
    end,
  })
end

return M
