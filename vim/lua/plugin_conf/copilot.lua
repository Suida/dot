local copilot_status_ok, _ = pcall(require, 'copilot')
if not copilot_status_ok then
  return
end

vim.keymap.set('i', '<C-f>', 'copilot#Accept("\\<C-o>l")', {
  expr = true,
  replace_keycodes = false,
  noremap = true,
})
vim.keymap.set('i', "<M-n>", '<Plug>(copilot-next)')
vim.keymap.set('i', '<M-p>', '<Plug>(copilot-previous)')

vim.g.copilot_no_tab_map = true
