return {
  append_slash = function (path)
    if path:sub(#path, #path) ~= '/' then
      return path .. '/'
    end
    return path
  end,

  has_words_before = function ()
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
  end
}
