local codecompanion_status_ok, codecompanion = pcall(require, 'codecompanion')
if not codecompanion_status_ok then
  return
end

codecompanion.setup({
  opts = {
    log_level = "DEBUG",
  },
  adapters = {
    http = {
      opts = {
        show_model_choices = true,
      },
      deepseek = function()
        return require("codecompanion.adapters").extend("deepseek", {
          opts = {
            stream = true,
            tools = true,
            vision = true,
          },
          features = {
            text = true,
            tokens = true,
          },
          schema = {
            model = {
              default = "deepseek-chat",
              choices = {
                "deepseek-chat",
                ["deepseek-reasoner"] = { can_reason = true, },
              },
            },
            temperature = {
              default = 0.4,
            },
            max_tokens = {
              default = 8192,
            },
          },
        })
      end,
      qwen = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          name = "Qwen3",
          opts = {
            stream = true,
            tools = true,
            vision = true,
          },
          features = {
            text = true,
            tokens = true,
          },
          roles = {
            llm = "assistant",
            user = "user",
          },
          env = {
            api_key = "DASHSCOPE_API_KEY",
            url = "https://dashscope.aliyuncs.com",
            chat_url = "/compatible-mode/v1/chat/completions",
            models_endpoint = nil,
          },
          schema = {
            model = {
              default = "qwen3-coder-flash",
              choices = {
                "qwen3-coder-flash",
                "qwen3-coder-plus",
                ["qwen-plus"] = {
                  can_reason = true,
                },
              },
            },
            temperature = {
              default = 0.4,
            },
            max_tokens = {
              default = 8192,
            },
          },
        })
      end,
    },
  },
  strategies = {
    chat = {
      adapter = "deepseek",
      keymaps = {
        send = {
          modes = { n = "<C-g>", i = "<C-g>" },
        },
        close = {
          modes = { n = "<C-x>x", i = "<C-x>x" },
        },
      },
    },
    inline = { adapter = "deepseek" },
    agent = { adapter = "deepseek" },
  },
  display = {
    chat = {
      start_in_insert_mode = false,

      -- Change the default icons
      icons = {
        pinned_buffer = " ",
        watched_buffer = "👀 ",
        chat_context = "📎️", -- You can also apply an icon to the fold
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
        sticky = true, -- when set to true and `layout` is not `"buffer"`, the chat buffer will remain opened when switching tabs
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
vim.keymap.set('n', '<leader>al', codecompanion.actions, opts)
vim.keymap.set('n', '<leader>an', codecompanion.chat, opts)
vim.keymap.set({ 'n', 't' }, '<leader>ap', codecompanion.toggle, opts)

