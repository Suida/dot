local treesitter_status_ok, _ = pcall(require, 'nvim-treesitter')
if not treesitter_status_ok then
  return
end

require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "c", "cpp", "lua", "vim", "vimdoc", "query", "python", "latex", "verilog",
  },
  highlight = {
    enable = true,
  },
}
