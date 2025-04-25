local M = {}

M.setup = function(dap)
  dap.adapters.python = {
    type = 'executable',
    command = 'python',
    args = { '-m', 'debugpy.adapter' },
  }

  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'Debug pytest expression',
      module = 'pytest',
      args = function()
        local pattern = vim.fn.input({
          prompt = "pytest -k ",
          default = require("user.utils").get_class_or_method_name(),
        });
        return { "-k", pattern };
      end,
      justMyCode = false,

    },
    {
      type = 'python',
      request = 'launch',
      name = 'Debug pytest for a file',
      module = 'pytest',
      args = { "${file}" },
      justMyCode = false,  -- Set to true to skip stdlib/internal modules
    },
  }
end

return M
