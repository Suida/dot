-- Resolve the nvim-agent dir from this script's path so tests can run from any cwd.
local src = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
local tests = vim.fn.fnamemodify(src, ':h')           -- nvim-agent/tests
-- Strip trailing separator: on Windows ':p' yields a trailing '\' which
-- breaks runtime-file lookup (nvim_get_runtime_file) for that entry.
local dir = vim.fn.fnamemodify(tests, ':h'):gsub('[\\/]$', '')  -- nvim-agent
vim.opt.rtp:prepend(dir)
-- With '-u NONE' the rtp lua loader (vim.loader) is not enabled by default,
-- so require('agent.*') would not search the runtimepath without this.
if vim.loader then vim.loader.enable() end
-- Windows: when nvim is launched from Git Bash, SHELL leaks into 'shell' while
-- 'shellcmdflag' stays at the cmd.exe default (/s /c). String-form termopen
-- then fails to launch, and a failed terminal launch can crash nvim once the
-- terminal buffer has been shown in a window. Emulate the standard Windows
-- shell for tests.
if vim.fn.has('win32') == 1 and vim.o.shellcmdflag == '/s /c'
  and vim.o.shell:lower():match('[\\/][a-z]*sh%.exe') then
  vim.o.shell = 'cmd.exe'
end
