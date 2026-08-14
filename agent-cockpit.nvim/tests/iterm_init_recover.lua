-- Integration-test init (crash recovery): same bootstrap as iterm_init.lua,
-- but with auto_recover = 'always' so a dirty manifest respawns workers
-- without prompting. socket.ensure probes and rebinds a stale address left
-- by a force-killed server.
local src = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
local tests = vim.fn.fnamemodify(src, ':h')                    -- agent-cockpit.nvim/tests
-- Strip trailing separator: on Windows ':p' yields a trailing '\' which
-- breaks runtime-file lookup for that entry.
local dir = vim.fn.fnamemodify(tests, ':h'):gsub('[\\/]$', '') -- agent-cockpit.nvim
vim.opt.rtp:prepend(dir)
-- With '-u <file>' the rtp lua loader may not be enabled.
if vim.loader then vim.loader.enable() end
-- Windows: emulate the standard shell when launched from Git Bash (see profile).
if vim.fn.has('win32') == 1 and vim.o.shellcmdflag == '/s /c'
  and vim.o.shell:lower():match('[\\/][a-z]*sh%.exe') then
  vim.o.shell = 'cmd.exe'
end
require('agent-cockpit').setup({ auto_recover = 'always', main_agent = false })
