local lualine_status_ok, lualine = pcall(require, 'lualine')
if not lualine_status_ok then
  return
end

local web_devicons_status_ok, _ = pcall(require, 'nvim-web-devicons')
if not web_devicons_status_ok then
  return
end

lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = '',
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    }
  },
  -- sections = {
  --   lualine_a = { { 'mode', separator = { left = ' ', right = '' }, right_padding = 2 } },
  --   lualine_b = {},
  --   lualine_c = {
  --     {
  --       'filename',
  --       symbols = {
  --         modified = '',
  --         readonly = '',
  --         unnamed  = '󰑕',
  --         newfile  = '',
  --       },
  --     },
  --   },
  --   lualine_x = {},
  --   lualine_y = {},
  --   lualine_z = {}
  -- },
  sections = {
    lualine_a = { { 'mode', separator = { left = ' ' }, right_padding = 2 } },
    lualine_b = {
      'branch',
    },
    lualine_c = {
      '%=',
      {
        'filename',
        symbols = {
          modified = '',
          readonly = '',
          unnamed  = '󰑕',
          newfile  = '',
        },
      },
      { 'diagnostics', },
    },
    lualine_x = {},
    lualine_y = {
      'filetype',
      'progress',
    },
    lualine_z = {
      { 'location', separator = { right = ' ' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {
      {
        'filename',
        symbols = {
          modified = '',
          readonly = '',
          unnamed  = '󰑕',
          newfile  = '',
        },
      },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
