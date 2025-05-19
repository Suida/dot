local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏", }
local spinner_index = 1
local notifier_id = "llm_request_notifier"

local request_timer = nil

local M = {}

M.requesting_worker = function(model_name, timeout)
  vim.notify("Requesting " .. model_name .. "...", "info", {
    id = notifier_id,
    title = "CodeCompanion",
    opts = function(notif)
      notif.icon = spinner[spinner_index]
    end,
  })
  spinner_index = spinner_index == 10 and 1 or spinner_index + 1
  request_timer = vim.defer_fn(function() M.requesting_worker(model_name, timeout) end, timeout);
end

M.finish_request = function(model_name, status)
  if request_timer ~= nil then
    vim.loop.timer_stop(request_timer)
    request_timer = nil
  end

  local lvl = " "
  local msg = " "
  local icon = ""

  if status == "success" then
    lvl = lvl .. "info"
    msg = msg .. "completed"
    icon = ""
  elseif status == "error" then
    lvl = lvl .. "error"
    msg = msg .. "failed"
    icon = ""
  else
    lvl = lvl .. "info"
    msg = msg .. "cancelled"
    icon = "󰜺"
  end

  vim.notify("Request to " .. model_name .. msg, lvl, {
    id = notifier_id,
    title = "CodeCompanion",
    opts = function(notif)
      notif.icon = icon
    end,
  })
end

M.setup = function(opts)
  local group = vim.api.nvim_create_augroup("llm_request_notify", { clear = true })
  local timeout = 80
  if opts and opts.timeout then
    timeout = opts.timeout
  end

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "CodeCompanionRequest*",
    callback = function(req)
      local adapter = req.data.adapter
      local model_name = adapter.model

      if req.match == "CodeCompanionRequestStarted" then
        M.requesting_worker(model_name, timeout)
      elseif req.match == "CodeCompanionRequestFinished" then
        M.finish_request(model_name, req.data.status)
      end
    end,
  })
end

return M
