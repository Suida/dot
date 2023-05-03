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
vim.keymap.set('n', '<A-Backspace>', [[:FloatermToggle<CR>]], opts)
vim.keymap.set('t', '<A-Backspace>', [[<C-\><C-n>:exe "sleep 100m \| FloatermToggle"<CR>]], opts)
vim.keymap.set('t', '<C-v>', [[<C-\><C-n>:exe "sleep 100m \| FloatermNew"<CR>]], opts)
vim.keymap.set('t', '<C-x>', [[<C-\><C-n>:exe "sleep 100m \| FloatermKill"<CR>]], opts)
vim.keymap.set('t', '<C-l>', [[<C-\><C-n>:exe "sleep 100m \| FloatermNext"<CR>]], opts)
vim.keymap.set('t', '<C-h>', [[<C-\><C-n>:exe "sleep 100m \| FloatermPrev"<CR>]], opts)

vim.cmd [[
  augroup floater_color
  autocmd!
  autocmd BufEnter * hi! link FloatermBorder CursorLineNr
  augroup END
]]


