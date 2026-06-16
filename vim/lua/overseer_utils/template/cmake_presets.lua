local overseer_status_ok, overseer = pcall(require, 'overseer')
if not overseer_status_ok then
  return
end

local preset_filenames = {
  'CMakePresets.json',
  'CMakeUserPresets.json',
}

local components = {
  { 'on_output_quickfix', open = true },
  'on_result_diagnostics',
  'default',
}

local function joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end

  local sep = package.config:sub(1, 1)
  return table.concat({ ... }, sep)
end

local function normalize(path)
  if vim.fs and vim.fs.normalize then
    return vim.fs.normalize(path)
  end

  return vim.fn.fnamemodify(path, ':p')
end

local function as_list(value)
  if value == nil then
    return {}
  end
  if type(value) == 'string' then
    return { value }
  end
  if type(value) == 'table' then
    return value
  end

  return {}
end

local function read_json(path)
  local lines = vim.fn.readfile(path)
  local ok, data = pcall(vim.json.decode, table.concat(lines, '\n'))
  if ok and type(data) == 'table' then
    return data
  end

  return nil
end

local function add_presets(dest, kind, presets)
  for _, preset in ipairs(as_list(presets)) do
    if type(preset) == 'table' and preset.name and not preset.hidden then
      dest[kind][preset.name] = preset
    end
  end
end

local function load_preset_file(path, seen, result)
  path = normalize(path)
  if seen[path] or vim.fn.filereadable(path) == 0 then
    return
  end
  seen[path] = true

  local data = read_json(path)
  if not data then
    return
  end

  local dir = vim.fn.fnamemodify(path, ':p:h')
  for _, include in ipairs(as_list(data.include)) do
    load_preset_file(joinpath(dir, include), seen, result)
  end

  add_presets(result, 'configure', data.configurePresets)
  add_presets(result, 'build', data.buildPresets)
  add_presets(result, 'test', data.testPresets)
end

local function find_preset_root(dir)
  local matches = vim.fs.find(preset_filenames, {
    path = dir,
    upward = true,
    type = 'file',
  })

  if #matches == 0 then
    return nil
  end

  return vim.fn.fnamemodify(matches[1], ':p:h')
end

local function load_presets(root)
  local result = {
    configure = {},
    build = {},
    test = {},
  }
  local seen = {}

  for _, filename in ipairs(preset_filenames) do
    load_preset_file(joinpath(root, filename), seen, result)
  end

  return result
end

local function sorted_presets(presets)
  local result = {}
  for _, preset in pairs(presets) do
    table.insert(result, preset)
  end
  table.sort(result, function(a, b)
    return a.name < b.name
  end)

  return result
end

local function make_task(name, cmd, cwd, tags)
  return {
    name = name,
    tags = tags,
    builder = function()
      return {
        cmd = cmd,
        cwd = cwd,
        components = components,
      }
    end,
  }
end

overseer.register_template({
  name = 'cmake presets',
  cache_key = function(opts)
    return find_preset_root(opts.dir)
  end,
  generator = function(opts)
    local root = find_preset_root(opts.dir)
    if not root then
      return {}
    end

    local presets = load_presets(root)
    local tasks = {}

    for _, preset in ipairs(sorted_presets(presets.configure)) do
      table.insert(tasks, make_task(
        'cmake configure: ' .. preset.name,
        { 'cmake', '--preset', preset.name },
        root,
        { 'BUILD' }
      ))
    end

    for _, preset in ipairs(sorted_presets(presets.build)) do
      table.insert(tasks, make_task(
        'cmake build: ' .. preset.name,
        { 'cmake', '--build', '--preset', preset.name },
        root,
        { 'BUILD' }
      ))
    end

    for _, preset in ipairs(sorted_presets(presets.test)) do
      table.insert(tasks, make_task(
        'cmake test: ' .. preset.name,
        { 'ctest', '--preset', preset.name },
        root,
        { 'TEST' }
      ))
    end

    return tasks
  end,
})
