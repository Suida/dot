local detect_windows_theme = require('user.utils').detect_windows_theme;

local M = {}

M.previous_mode = ''

M.inner_worker = function()
  detect_windows_theme(function (mode)
    if M.previous_mode:match(mode) then
      return;
    end
    M.previous_mode = mode
    if mode:match('dark') then
      vim.schedule(function()
        vim.o.background = 'dark';
        vim.cmd.colorscheme 'rose-pine-moon';
      end)
    elseif mode:match('light') then
      vim.schedule(function()
        vim.o.background = 'light';
        vim.cmd.colorscheme 'rose-pine-dawn';
      end)
    else
      print("Color mode not resolved");
    end
  end)
  vim.defer_fn(M.inner_worker, 10000);
end

M.worker = function ()
  vim.defer_fn(M.inner_worker, 1000);
end

M.setup = function ()
  M.worker();
end

return M
