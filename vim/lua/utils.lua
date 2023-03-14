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

  get_tab_width = function ()
    local winl = vim.api.nvim_tabpage_list_wins(0)
    local most_r_win_nr = 0
    local mr_col, cur_col = -1, 0

    for _, win_nr in ipairs(winl) do
      cur_col = vim.api.nvim_win_get_position(win_nr)[2]
      if mr_col < cur_col  then
        most_r_win_nr = win_nr
        mr_col = cur_col
      end
    end

    return mr_col + vim.api.nvim_win_get_width(most_r_win_nr)
  end,

  get_tab_height = function ()
    local winl = vim.api.nvim_tabpage_list_wins(0)
    local most_d_win_nr = 0
    local md_row, cur_row = -1, 0

    for _, win_nr in ipairs(winl) do
      cur_row = vim.api.nvim_win_get_position(win_nr)[1]
      if md_row < cur_row  then
        most_d_win_nr = win_nr
        md_row = cur_row
      end
    end

    return md_row + vim.api.nvim_win_get_height(most_d_win_nr)
  end,
}
