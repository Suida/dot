local telekasten_status_ok, telekasten = pcall(require, 'telekasten')
if not telekasten_status_ok then
  return
end

local zk_home = vim.fn.expand('$ZK_NOTEBOOK_DIR')
local template_dir = zk_home .. '/templates'

telekasten.setup({
  home = zk_home,
  tag_notation = 'yaml-bare',
  auto_set_filetype = false,
  dailies = zk_home .. '/daily',
  weeklies = zk_home .. '/weekly',
  template_new_note = template_dir .. '/base.md',
  template_new_daily = template_dir .. '/base.md',
  template_new_weekly = template_dir .. '/base.md',
})

-- Launch panel if nothing is typed after <leader>z
vim.keymap.set('n', '<leader>z', '<cmd>Telekasten panel<CR>')

-- Most used functions
vim.keymap.set('n', '<leader>zf', '<cmd>Telekasten find_notes<CR>')
vim.keymap.set('n', '<leader>zg', '<cmd>Telekasten search_notes<CR>')
vim.keymap.set('n', '<leader>zd', '<cmd>Telekasten goto_today<CR>')
vim.keymap.set('n', '<leader>zz', '<cmd>Telekasten follow_link<CR>')
vim.keymap.set('n', '<leader>zn', '<cmd>Telekasten new_note<CR>')
vim.keymap.set('n', '<leader>zc', '<cmd>Telekasten show_calendar<CR>')
vim.keymap.set('n', '<leader>zb', '<cmd>Telekasten show_backlinks<CR>')
vim.keymap.set('n', '<leader>zI', '<cmd>Telekasten insert_img_link<CR>')

