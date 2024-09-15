local hop_status_ok, hop = pcall(require, 'hop')
if not hop_status_ok then
  return
end

local directions = require('hop.hint').HintDirection

vim.keymap.set('n', 'S', function()
  hop.hint_char1({ direction = nil, current_line_only = false })
end, {remap=true})

vim.keymap.set('n', '<leader>F', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, {remap=true})

vim.keymap.set('n', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('n', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('n', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, {remap=true})

vim.keymap.set('n', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, {remap=true})
