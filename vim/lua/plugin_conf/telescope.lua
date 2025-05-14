local telescope_status_ok, telescope = pcall(require, 'telescope')
if not telescope_status_ok then
  return
end

local builtin = require 'telescope.builtin'

telescope.load_extension('media_files')
telescope.load_extension('bibtex')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fm', builtin.marks, {})

telescope.setup {
  extensions = {
    media_files = {
      filetypes = { 'png', 'jpg', 'mp4', 'webm', 'pdf' },
      find_cmd = 'rg',
    }
  },
  bibtex = {
    context = true,
    context_fallback = true,
  },
}
