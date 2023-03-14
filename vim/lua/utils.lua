return {
  append_slash = function (path)
    if path:sub(#path, #path) ~= '/' then
      return path .. '/'
    end
    return path
  end,
  has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end,
}
