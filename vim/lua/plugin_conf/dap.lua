local dap_status_ok, dap = pcall(require, 'dap')
if not dap_status_ok then
  return
end
local dapui, dap_lldb = require('dapui'), require('dap-lldb');
local dap_python = require('plugin_conf.dap-python');

dapui.setup()
dap_lldb.setup();
dap_python.setup(dap)

vim.keymap.set('n', '<F17>', function() require('dap').disconnect() end)  -- <F17> is <S-F5> in wezterm
vim.keymap.set('n', '<S-F5>', function() require('dap').disconnect() end)  -- <F17> is <S-F5> in wezterm
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F23>', function() require('dap').step_out() end)    -- <F23> is <S-F11> in wezterm
vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>dcb', function() require('dap').set_breakpoint(vim.fn.input("Condition: ")) end)
vim.keymap.set('n', '<Leader>dlp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>ddr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>ddl', function() require('dap').run_last() end)
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>dds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
