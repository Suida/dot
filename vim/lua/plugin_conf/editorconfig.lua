vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*', 'scp://.*' }
vim.cmd 'au FileType gitcommit let b:EditorConfig_disable = 1'

