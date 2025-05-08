local toggleterm_status_ok, toggleterm = pcall(require, 'toggleterm')
if not toggleterm_status_ok then
  return
end
local utils = require 'user.utils';

local shell;

if utils.get_os_type() == 'unix' then
  shell = [[/usr/bin/zsh]];
else
  shell = [[pwsh.exe]];
end


toggleterm.setup({
  shell = shell,
  size = function(term)
    if term.direction == 'horizontal' then
      return math.max(utils.get_tab_height() / 3, 20);
    elseif term.direction == 'vertical' then
      return math.max(utils.get_tab_width() / 5, 50);
    end
  end,
});

local toggle_keys = '<A-d>%d'
local toggle_cmd = '<cmd>ToggleTerm %d<CR>'

local opts = { noremap = true, silent = true }
for i = 1,9 do
  vim.keymap.set({ 'n', 't' }, string.format(toggle_keys, i), string.format(toggle_cmd, i), opts)
end
vim.keymap.set({ 'n', 't' }, '<A-Backspace>',  '<cmd>ToggleTermToggleAll<CR>', opts)


-- Lazygit Integration
local Terminal = require('toggleterm.terminal').Terminal;

local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "double",
  },
  -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.keymap.set("n", "q", "<cmd>close<CR>", { noremap = true, silent = true, buffer = term.bufnr, });
    -- print(term.bufnr)
    -- vim.defer_fn(function ()
      vim.keymap.del({ 'i', 't' }, 'jk');
    -- end, 3000);
  end,
  -- function to run on closing the terminal
  on_close = function(term)
    vim.keymap.set({ 'i', 't' }, 'jk', [[<C-\><C-n>]], { noremap = true })
    vim.cmd("startinsert!")
  end,
})

local function _lazygit_toggle()
  lazygit:toggle()
end

vim.keymap.set('n',  "<leader>gl", function() _lazygit_toggle() end)

