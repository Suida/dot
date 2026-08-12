-- Usage: nvim --headless -u NONE -l nvim-agent/tests/run.lua   (from repo root)
-- Strip trailing separator: on Windows ':p' yields a trailing '\' which
-- breaks runtime-file lookup (nvim_get_runtime_file) for that entry.
local dir = vim.fn.fnamemodify('./nvim-agent', ':p'):gsub('[\\/]$', '')
vim.opt.rtp:prepend(dir)
-- With '-u NONE' the rtp lua loader (vim.loader) is not enabled by default,
-- so require('agent.*') would not search the runtimepath without this.
if vim.loader then vim.loader.enable() end
