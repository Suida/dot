local detect_windows_theme = require('user.utils').detect_windows_theme;

M = {
  previous_mode = '',
  worker = function ()
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
    vim.defer_fn(M.worker, 10000);
  end,
  setup = function ()
    detect_windows_theme(function (mode)
      M.previous_mode = mode;
    end);
    M.worker();
  end
}

return M
