vim.g.lightline = {
  colorscheme = 'solarized',
  background = 'dark',
  active = {
    left = {
      { 'mode', 'paste' },
      { 'gitbranch', 'readonly', 'filename', 'modified' }
    }
  },
  component_function = {
    gitbranch = 'EmojiedFugitiveHead'
  },
  separator = { left = "", right = "" },
  subseparator = { left = "", right = "" },
  tabline_separator = { left = "", right = "" },
  tabline_subseparator = { left = "", right = "" },
}

vim.g.EmojiedFugitiveHead = function()
  return ' ' .. vim.fn.FugitiveHead()
end

