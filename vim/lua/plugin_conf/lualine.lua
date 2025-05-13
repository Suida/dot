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
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
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
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        symbols = {
          modified = '[M]',
          readonly = '[R]',
          unnamed = '[No Name]',
          newfile = '[New]',
        },
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'branch', }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {
      {
        'filename',
        symbols = {
          modified = '[M]',
          readonly = '[R]',
          unnamed = '[No Name]',
          newfile = '[New]',
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
