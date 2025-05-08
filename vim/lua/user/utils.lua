M = {
  append_slash = function (path)
    local sep = ''
    if M.get_os_type() == 'win32' then
      sep = '\\'
    else
      sep = '/'
    end
    if path:sub(#path, #path) ~= sep then
      return path .. sep
    end
    return path
  end,

  has_words_before = function ()
    ---@diagnostic disable-next-line: deprecated
    local unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end,

  -- Find the right most non-relative window, add its col position and width
  -- as tab width.
  get_tab_width = function ()
    local winl = vim.api.nvim_tabpage_list_wins(0)
    local most_r_win_nr = 0
    local mr_col, cur_col = -1, 0

    for _, win_nr in ipairs(winl) do
      if vim.api.nvim_win_get_config(win_nr)['relative'] ~= "" then
        goto continue
      end
      cur_col = vim.api.nvim_win_get_position(win_nr)[2]
      if mr_col < cur_col  then
        most_r_win_nr = win_nr
        mr_col = cur_col
      end
      ::continue::
    end

    return mr_col + vim.api.nvim_win_get_width(most_r_win_nr)
  end,

  -- Quite same as `get_tab_width`
  get_tab_height = function ()
    local winl = vim.api.nvim_tabpage_list_wins(0)
    local most_d_win_nr = 0
    local md_row, cur_row = -1, 0

    for _, win_nr in ipairs(winl) do
      if vim.api.nvim_win_get_config(win_nr)['relative'] ~= "" then
        goto continue
      end
      cur_row = vim.api.nvim_win_get_position(win_nr)[1]
      if md_row < cur_row  then
        most_d_win_nr = win_nr
        md_row = cur_row
      end
    ::continue::
    end

    return md_row + vim.api.nvim_win_get_height(most_d_win_nr)
  end,

  get_os_type = function ()
    return package.config:sub(1,1) == '/' and 'unix' or 'win32'
  end,

  detect_windows_theme = function (cb)
    local handle
    local stdout = vim.loop.new_pipe(false)
    local result = ''

    -- Define the PowerShell command to check the Windows theme
    local cmd = [[(Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize').AppsUseLightTheme]]

    -- Run the command asynchronously using vim.loop
    handle = vim.loop.spawn('pwsh.exe', {
      args = { '-nop', '-Command', cmd },
      stdio = {nil, stdout, nil},
    }, function(code, signal)
      stdout:read_stop()
      stdout:close()
      handle:close()
      -- Use the callback function to return the result
      if cb then cb(result) end
    end)

    -- Capture the output
    stdout:read_start(function(err, data)
      if data then
        if data:match('0') then
          result = result .. 'dark'
        elseif data:match('1') then
          result = result .. 'light'
        end
      end
    end)
  end,

  -- Using asynchronous API, auto-detect system's color mode,
  -- based on which set Neovim's color scheme
  auto_color_config = function(light, dark)
    require('user.utils').detect_windows_theme(function(mode)
      if mode:match('dark') then
        vim.schedule(function()
          vim.o.background = 'dark'
          vim.cmd('colorscheme ' .. dark)
        end)
      elseif mode:match('light') then
        vim.schedule(function()
          vim.o.background = 'light'
          vim.cmd('colorscheme ' .. light)
        end)
      else
        vim.schedule(function()
          vim.notify("Color mode not detected!", vim.log.levels.ERROR)
        end)
      end
    end);
  end,

  get_class_or_method_name = function()
    local ts_utils = require("nvim-treesitter.ts_utils")

    local node = ts_utils.get_node_at_cursor()
    while node do
      if node:type() == "function_definition" or node:type() == "function_declaration" or node:type() == "method_definition" then
        for i = 0, node:child_count() - 1 do
          local child = node:child(i)
          if child:type() == "identifier" then
            return vim.treesitter.get_node_text(child, 0)
          end
        end
      end
      node = node:parent()
    end
    return nil
  end,
}

return M
