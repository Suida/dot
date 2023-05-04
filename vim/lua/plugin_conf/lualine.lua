local lualine_status_ok, lualine = pcall(require, 'lualine')
if not lualine_status_ok then
  return
end

local web_devicons_status_ok, web_devicons = pcall(require, 'nvim-web-devicons')
if not web_devicons_status_ok then
  return
end

local utils = require 'user.utils'

local tab_no = function ()
  return vim.fn.tabpagenr()
end

lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {{
      'tabs',
      mode = 2,
      max_length = function ()
        return utils.get_tab_width() * 9 / 10
      end,
      fmt = function(name, context)
        local buflist = vim.fn.tabpagebuflist(context.tabnr)
        local winnr = vim.fn.tabpagewinnr(context.tabnr)
        local bufnr = buflist[winnr]
        local mod = vim.fn.getbufvar(bufnr, '&mod')
        local icon, _ = web_devicons.get_icon(name)
        if icon ~= nil then
          return icon .. ' ' .. name .. (mod == 1 and ' +' or '')
        else
          return name .. (mod == 1 and ' +' or '')
        end
      end
    }},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { tab_no }
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
