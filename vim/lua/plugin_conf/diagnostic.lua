local severity = vim.diagnostic.severity

local signs = {
  [severity.ERROR] = " ",
  [severity.WARN]  = " ",
  [severity.HINT]  = " ",
  [severity.INFO]  = " ",
}

vim.diagnostic.config({
  signs = {
    text = signs,
  },
})
