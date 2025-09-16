local snacks = require('snacks')

M = {}

M.setup = function(dap)

  -- local dap_exe_config = {
  --   type = 'python',
  --   request = 'launch',
  --   name = 'Executable',
  -- };
  --
  -- local dap_exe_config_meta = {
  --   __call = function (t, ...)
  --     local ext = {}
  --     snacks.input.input({ prompt = 'Python module: ' }, function (pymod)
  --       if not pymod then
  --         ext.module = function () return dap.ABORT end
  --         ext.args = {}
  --       end
  --       ext.module = pymod
  --
  --       snacks.input.input({ prompt = 'Arguments: ' }, function (pyarg)
  --         ext.args = {}
  --
  --         if not pyarg then
  --           return
  --         end
  --
  --         for arg in string.gmatch(pyarg, "%S+") do
  --           table.insert(t.args, arg)
  --         end
  --       end)
  --     end)
  --
  --     return t
  --   end
  -- }
  --
  -- setmetatable(dap_exe_config, dap_exe_config_meta)

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
      justMyCode = false, -- Set to true to skip stdlib/internal modules
    },
    {
      type = 'python',
      request = 'launch',
      name = 'Run current file',
      program = "${file}",
      args = function()
        return coroutine.create(function(dap_run_co)
          snacks.input.input({ prompt = 'Arguments (space separated): ' }, function(python_args)
            local args = {}

            if python_args then
              for arg in string.gmatch(python_args, "%S+") do
                table.insert(args, arg)
              end
            end
            coroutine.resume(dap_run_co, args)
          end)
        end)
      end,
    },
    -- dap_exe_config,
  }
end

return M
