vim.g.mkdp_port = '34910'
vim.g.mkdp_refresh_slow = 1
vim.g.mkdp_open_to_the_world = 1
vim.g.mkdp_echo_preview_url = 1
vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', { noremap = true })
vim.keymap.set('n', '<leader>ms', ':MarkdownPreviewStop<CR>', { noremap = true })

