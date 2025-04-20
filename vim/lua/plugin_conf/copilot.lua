vim.keymap.set('i', '<C-f>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.keymap.set('i', "<M-n>", '<Plug>(copilot-next)')
vim.keymap.set('i', '<M-p>', '<Plug>(copilot-previous)')

vim.g.copilot_no_tab_map = true
