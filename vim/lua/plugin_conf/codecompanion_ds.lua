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
                "qwen3.6-plus",
                "qwen3-coder-flash",
                "qwen3-coder-plus",
                ["qwen-plus"] = {
                  can_reason = true,
                },
                "glm-5",
                "kimi/kimi-k2.5",
              },
            },
            temperature = {
              default = 0.4,
            },
            max_tokens = {
              default = 16384,
            },
          },
        })
      end,
    },
    acp = {
      kimi = function()
        return require("codecompanion.adapters").extend("kimi_cli", {
          name = "kimi",
          formatted_name = "Kimi CLI",
          commands = {
            default = {
              "kimi",
              "acp",
            },
          },
          handlers = {
            auth = function()
              return true
            end,
          },
        })
      end,
      claude_kimi = function()
        return require("codecompanion.adapters").extend("claude_code", {
          name = "claude_kimi",
          formatted_name = "Claude Code with Kimi",
          env = {
            ANTHROPIC_BASE_URL = "https://api.kimi.com/coding/",
            ANTHROPIC_API_KEY = "sk-kimi-AMhr2745MRjZDHjHOF0w67DTbHtKq2GiOAeTG5OeQVEIcVGBdFGnG0SaCbrwlEqb",
            ANTHROPIC_MODEL = "kimi-for-coding",
          }
        })
      end,
      claude_qwen = function()
        return require("codecompanion.adapters").extend("claude_code", {
          name = "claude_qwen",
          formatted_name = "Claude Code with Qwen",
          env = {
            ANTHROPIC_BASE_URL = "https://dashscope.aliyuncs.com/apps/anthropic",
            ANTHROPIC_MODEL = "qwen3.5-plus",
            ANTHROPIC_API_KEY = "DASHSCOPE_API_KEY",
          }
        })
      end,
    }
  },
  interactions = {
    chat = {
      adapter = "kimi",
      keymaps = {
        send = {
          modes = { n = "<C-g>", i = "<C-g>" },
        },
        close = {
          modes = { n = "<C-x>x", i = "<C-x>x" },
        },
      },
    },
    inline = { adapter = "claude_kimi" },
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

vim.keymap.set('n', '<leader>al', codecompanion.actions, { desc = "CodeCompanion actions", noremap = true, silent = true })
vim.keymap.set('n', '<leader>an', codecompanion.chat, { desc = "CodeCompanion chat", noremap = true, silent = true })
vim.keymap.set('n', '<leader>ap', codecompanion.toggle, { desc = "CodeCompanion toggle", noremap = true, silent = true })
