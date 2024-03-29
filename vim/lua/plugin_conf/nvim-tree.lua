local nvim_tree_status_ok, nvim_tree = pcall(require, "nvim-tree")
if not nvim_tree_status_ok then
  return
end

local utils = require 'user.utils'

local on_attach = require("plugin_conf.nvim-tree-on-attach")

nvim_tree.setup({
  on_attach = on_attach,
  hijack_netrw = false,
  view = {
    side = "right",
    number = true,
    relativenumber = true,
    signcolumn = "yes",
    preserve_window_proportions = true,

    float = {
      enable = true,
      quit_on_focus_loss = true,
      open_win_config = function()
        return {
          relative = "editor",
          anchor = 'NE',
          width = 40,
          height = utils.get_tab_height() - 3,
          row = 1,
          col = utils.get_tab_width() - 1,
          border = {
            { "╔", "CursorLineNr" },
            { "═", "CursorLineNr" },
            { "╗", "CursorLineNr" },
            { "║", "CursorLineNr" },
            { "╝", "CursorLineNr" },
            { "═", "CursorLineNr" },
            { "╚", "CursorLineNr" },
            { "║", "CursorLineNr" },
          }
        }
      end,
    }
  },
  respect_buf_cwd = true,
  actions = {
    open_file = {
      resize_window = false,
    },
  },
})
vim.cmd [[nnoremap <silent> <leader>e :NvimTreeToggle<CR>]]
vim.cmd [[
  augroup explorer
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * call handle_open_directory()
  augroup END
]]
vim.g.handle_open_directory = function()
  vim.cmd [[
    if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") 
      exe "cd" fnameescape(argv()[0])
      ene
      NvimTreeOpen
      sleep 100m
      wincmd w
    endif
  ]]
  end

