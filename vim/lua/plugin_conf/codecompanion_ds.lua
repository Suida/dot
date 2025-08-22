local codecompanion_status_ok, codecompanion = pcall(require, 'codecompanion')
if not codecompanion_status_ok then
  return
end

codecompanion.setup({
  adapters = {
    deepseek = function()
      return require("codecompanion.adapters").extend("deepseek", {
        url = "https://api.deepseek.com/chat/completions",
        env = {
          api_key = os.getenv("DEEPSEEK_API_KEY"),
        },
        schema = {
          model = {
            default = "deepseek-coder",
            choices = {
              ["deepseek-coder"] = { opts = { can_use_tools = true } },
            },
          },
          temperature = {
            default = 0.1,
          },
          num_ctx = {
            default = 16384,
          },
          num_predict = {
            default = -1,
          },
        },
      })
    end,
  },
  strategies = {
    chat = {
      adapter = "deepseek",
      keymaps = {
        send = {
          modes = { n = "<C-g>", i = "<C-g>" },
        },
        close = {
          modes = { n = "<C-c>", i = "<C-c><C-c>" },
        },
      },
    },
    inline = { adapter = "deepseek" },
    agent = { adapter = "deepseek" },
  },
  display = {
    chat = {
      show_settings = true,
      start_in_insert_mode = false,

      -- Change the default icons
      icons = {
        pinned_buffer = " ",
        watched_buffer = "👀 ",
      },

      -- Alter the sizing of the debug window
      debug_window = {
        ---@return number|fun(): number
        width = vim.o.columns - 5,
        ---@return number|fun(): number
        height = vim.o.lines - 2,
      },

      -- Options to customize the UI of the chat buffer
      window = {
        layout = "vertical", -- float|vertical|horizontal|buffer
        position = "right", -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
        border = "single",
        height = 0.7,
        width = 80,
        relative = "editor",
        full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
        opts = {
          number = false,
          relativenumber = false,
          breakindent = true,
          cursorcolumn = false,
          cursorline = false,
          foldcolumn = "0",
          foldenable = true,
          foldlevel = 3,
          linebreak = true,
          list = false,
          numberwidth = 1,
          signcolumn = "no",
          spell = false,
          wrap = true,
        },
      },

      token_count = function(tokens, _)
        return " (" .. tokens .. " tokens)"
      end,
    },
  },
})

require('plugin_conf.codecompanion-notify').setup()

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>at', codecompanion.actions, opts)
vim.keymap.set('n', '<leader>an', codecompanion.chat, opts)
vim.keymap.set({ 'n', 'i', 't' }, '<A-a>', codecompanion.toggle, opts)
