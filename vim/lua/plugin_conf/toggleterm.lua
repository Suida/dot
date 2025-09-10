local toggleterm_status_ok, toggleterm = pcall(require, 'toggleterm')
if not toggleterm_status_ok then
  return
end
local terms = require('toggleterm.terminal')
local ui = require('toggleterm.ui')
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
      return math.max(utils.get_tab_height() / 3, 16);
    elseif term.direction == 'vertical' then
      return math.max(utils.get_tab_width() / 2, 120);
    end
  end,
  winbar = {
    enabled = true,
    name_formatter = function(term) --  term: Terminal
      return '   [' .. term.id .. ']  '
    end
  },
});


local function toggle_selected_term(selected_term_id)
  local has_open, windows = ui.find_open_windows()
  if has_open then
    ui.close_and_save_terminal_view(windows)
  end

  -- If only the selected terminal is opened, close it and return
  if #windows == 1 and windows[1].term_id == selected_term_id then
    return
  end

  -- Open or create selected terminal
  local term = terms.get_or_create_term(selected_term_id)
  ui.update_origin_window(term.window)
  term:toggle()
  -- Save the terminal in view if it was last closed terminal.
  if not ui.find_open_windows() then ui.save_terminal_view({ term.id }, term.id) end
end


local toggle_keys = '<A-%d>'
local toggle_cmd = '<cmd>ToggleTerm %d<CR>'

local opts = { noremap = true, silent = true }
vim.keymap.set({ 'v' }, '<leader>dd', '<cmd>ToggleTermSendVisualLines 1<CR>', opts)
vim.keymap.set({ 'v' }, '<leader>ss', '<cmd>ToggleTermSendVisualSelection 1<CR>', opts)


for i = 1,9 do
  vim.keymap.set({ 'n', 'i', 't', }, string.format(toggle_keys, i), function () toggle_selected_term(i) end, opts)
  vim.keymap.set({ 'v' }, string.format('<leader>d%d', i), string.format('<cmd>ToggleTermSendVisualLines %d<CR>', i), opts)
  vim.keymap.set({ 'v' }, string.format('<leader>s%d', i), string.format('<cmd>ToggleTermSendVisualSelection %d<CR>', i), opts)
end
vim.keymap.set({ 'n', 'i', 't', }, '<A-Backspace>',  '<cmd>ToggleTermToggleAll<CR>', opts)

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

