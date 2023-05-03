local overseer_status_ok, overseer = pcall(require, 'overseer')
if not overseer_status_ok then
  return
end

local condition = {
  dir = vim.fn.expand('$ZK_NOTEBOOK_DIR'),
  callback = function()
    local f = io.open(vim.fn.expand('$ZK_NOTEBOOK_DIR/scripts/build.py'), 'r')
    if f ~= nil then
      io.close(f)
      return true
    else
      return false
    end
  end
}

local components = {
  { "on_output_quickfix", set_diagnostics = true },
  "on_result_diagnostics",
  "default",
}

local cmd_bin = vim.fn.expand('./scripts/build.py')

overseer.register_template {
  name = 'build all',
  builder = function()
    local cmd = { cmd_bin, }
    return {
      cmd = cmd,
      components = components,
    }
  end,
  condition = condition,
}

overseer.register_template {
  name = 'build all (force)',
  builder = function()
    local cmd = { cmd_bin, '-f', }
    return {
      cmd = cmd,
      components = components,
    }
  end,
  condition = condition,
}

overseer.register_template {
  name = 'build current file',
  builder = function()
    local file = vim.fn.expand('%:p')
    local cmd = { cmd_bin, file, }
    return {
      cmd = cmd,
      components = components,
    }
  end,
  condition = condition,
}

overseer.register_template {
  name = 'build current file (force)',
  builder = function()
    local file = vim.fn.expand('%:p')
    local cmd = { cmd_bin, '-f', file, }
    return {
      cmd = cmd,
      components = components,
    }
  end,
  condition = condition,
}

overseer.register_template {
  name = 'build current file as slides',
  builder = function()
    local file = vim.fn.expand('%:p')
    local cmd = { cmd_bin, file, '-zs', }
    return {
      cmd = cmd,
      components = components,
    }
  end,
  condition = condition,
}

overseer.register_template {
  name = 'build current file as slides (force)',
  builder = function()
    local file = vim.fn.expand('%:p')
    local cmd = { cmd_bin, '-f', file, '-zs', }
    return {
      cmd = cmd,
      components = components,
    }
  end,
  condition = condition,
}

