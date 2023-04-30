-- Overwrite the highlight of Conceal group
vim.cmd [[
  augroup conceal_color
    autocmd!
    autocmd BufEnter *.md,*.tex hi! link Conceal Constant
  augroup END
]]

