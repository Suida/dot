local cmake_status_ok, cmake = pcall(require, 'cmake-tools')
if not cmake_status_ok then
  return
end

local components = {
  { 'on_output_quickfix', open = true },
  'on_result_diagnostics',
  'default',
}

cmake.setup({
  cmake_use_preset = true,
  cmake_executor = {
    name = 'overseer',
    opts = {
      new_task_opts = {
        components = components,
      },
    },
  },
  cmake_runner = {
    name = 'overseer',
    opts = {
      new_task_opts = {
        components = components,
      },
    },
  },
})
