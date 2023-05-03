local overseer_status_ok, overseer = pcall(require, 'overseer')
if not overseer_status_ok then
  return
end

overseer.setup()

local keymap = vim.keymap.set
local opts = { silent = true, noremap = true }

keymap('n', '<leader>ot', overseer.toggle, opts)
keymap('n', '<leader>or', overseer.run_template, opts)

require 'overseer_utils.template.pandoc_build'

