local utils = require 'user.utils'

if utils.get_os_type() == 'unix' then
  vim.g.floaterm_shell = '/usr/bin/zsh'
else
  vim.g.floaterm_shell = [[pwsh.exe]]
end

local opts = { noremap = true, silent = true }

-- vim.g.floaterm_wintype = 'split'
vim.g.floaterm_width = 0.99999
vim.g.floaterm_height = 0.4
vim.g.floaterm_position = 'bottom'
vim.g.floaterm_borderchars = '─ ─ ┌┐┘└'
vim.keymap.set('n', '<C-t>t', [[:FloatermToggle<CR>]], opts)
vim.keymap.set('n', '<C-t>c', [[:FloatermNew<CR>]], opts)
vim.keymap.set('n', '<C-t>x', [[:FloatermKill<CR>]], opts)
vim.keymap.set('n', '<C-t>n', [[:FloatermNext<CR>]], opts)
vim.keymap.set('n', '<C-t>p', [[:FloatermPrev<CR>]], opts)
vim.keymap.set('t', '<C-t>t', [[<C-\><C-n>:exe "sleep 100m \| FloatermToggle"<CR>]], opts)
vim.keymap.set('t', '<C-t>c', [[<C-\><C-n>:exe "sleep 100m \| FloatermNew"<CR>]], opts)
vim.keymap.set('t', '<C-t>x', [[<C-\><C-n>:exe "sleep 100m \| FloatermKill"<CR>]], opts)
vim.keymap.set('t', '<C-t>n', [[<C-\><C-n>:exe "sleep 100m \| FloatermNext"<CR>]], opts)
vim.keymap.set('t', '<C-t>p', [[<C-\><C-n>:exe "sleep 100m \| FloatermPrev"<CR>]], opts)

vim.cmd [[
  augroup floater_color
  autocmd!
  autocmd BufEnter * hi! link FloatermBorder CursorLineNr
  augroup END
]]
