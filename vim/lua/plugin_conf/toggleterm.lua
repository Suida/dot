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
  direction = 'horizontal',
  size = function(term)
    if term.direction == 'horizontal' then
      return math.floor(math.max(utils.get_tab_height() / 3, 16));
    elseif term.direction == 'vertical' then
      return math.floor(math.max(utils.get_tab_width() / 4, 80));
    end
  end,
  winbar = {
    enabled = true,
    name_formatter = function(term) --  term: Terminal
      return '   [' .. term.id .. ']  '
    end
  },
});


local toggle_keys = '<A-%d>'

local opts = { noremap = true, silent = true }
vim.keymap.set({ 'v' }, '<leader>dd', '<cmd>ToggleTermSendVisualLines 1<CR>', opts)
vim.keymap.set({ 'v' }, '<leader>ss', '<cmd>ToggleTermSendVisualSelection 1<CR>', opts)


for i = 1,6 do
  vim.keymap.set({ 'n', 'i', 't', }, string.format(toggle_keys, i), function()
    require('user.agent_layout').main_terminal(i)
  end, opts)
  vim.keymap.set({ 'v' }, string.format('<leader>d%d', i), string.format('<cmd>ToggleTermSendVisualLines %d<CR>', i), opts)
  vim.keymap.set({ 'v' }, string.format('<leader>s%d', i), string.format('<cmd>ToggleTermSendVisualSelection %d<CR>', i), opts)
end
vim.keymap.set({ 'n', 'i', 't', }, '<A-`>', function()
  require('user.agent_layout').toggle_all_terminals_normal()
end, opts)

-- Lazygit Integration
vim.keymap.set('n', "<leader>gl", function()
  require('user.agent_layout').main_git()
end)
