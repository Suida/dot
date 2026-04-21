-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    {
      'williamboman/mason.nvim',
      { 'williamboman/mason-lspconfig.nvim', dependencies = { 'williamboman/mason.nvim' } },
      'neovim/nvim-lspconfig',
      {
        'mfussenegger/nvim-dap',
        dependencies = { 'folke/snacks.nvim' },
      },
      {
        'nvimtools/none-ls.nvim',
        ft = { 'lua', 'python' },
      }
    },
    {
      'nvim-treesitter/nvim-treesitter',
      branch = 'main',
      lazy = false,
      build = ':TSUpdate'
    },
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = "main",
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
      },
    },
    { 'rcarriga/nvim-dap-ui',            dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
    { 'suida/nvim-dap-lldb',             dependencies = { "mfussenegger/nvim-dap" } },
    { 'mfussenegger/nvim-dap-python',    dependencies = { "mfussenegger/nvim-dap" } },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante", "codecompanion" },
      },
      ft = { "markdown", "Avante", "codecompanion" },
      config = function()
        require('render-markdown').setup({
          html = {
            enabled = true,
            tag = {
              buf         = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
              file        = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
              help        = { icon = '󰘥 ', highlight = 'CodeCompanionChatVariable' },
              image       = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
              symbols     = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
              url         = { icon = '󰖟 ', highlight = 'CodeCompanionChatVariable' },
              var         = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
              tool        = { icon = ' ', highlight = 'CodeCompanionChatTool' },
              user_prompt = { icon = ' ', highlight = 'CodeCompanionChatTool' },
              group       = { icon = ' ', highlight = 'CodeCompanionChatToolGroup' },
            },
          },
        })
      end
    },
    {
      "olimorris/codecompanion.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "j-hui/fidget.nvim",
        {
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "markdown", "codecompanion" },
          },
          ft = { "markdown", "codecompanion" },
        },
      },
    },
    {
      "scalameta/nvim-metals",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      ft = { "scala", "sbt", "java" },
      config = function(self, metals_config)
        local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
          pattern = self.ft,
          callback = function()
            require("metals").initialize_or_attach(metals_config)
          end,
          group = nvim_metals_group,
        })
      end
    },

    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        { 'jc-doyle/cmp-pandoc-references' }
      }
    },

    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    -- Code template
    {
      'mattn/emmet-vim',
      init = function() vim.g.user_emmet_leader_key = '<C-x>' end
    },
    'honza/vim-snippets',

    -- Zettelkasten
    {
      'renerocksai/telekasten.nvim',
      dependencies = { 'nvim-telescope/telescope.nvim' }
    },
    'mzlogin/vim-markdown-toc',

    -- Git
    'lewis6991/gitsigns.nvim',
    -- Project-wide replace
    {
      'MagicDuck/grug-far.nvim',
      config = function()
        require('grug-far').setup({
        });
      end
    },
    -- Task runner
    'stevearc/overseer.nvim',

    -- Outlook
    'nvim-tree/nvim-web-devicons',
    {
      'rose-pine/neovim',
      lazy = false,
      config = function()
        -- require("rose-pine").setup {
        --   dim_inactive_windows = true,
        -- }
        vim.o.background = 'dark'
        vim.cmd('colorscheme rose-pine-moon')
      end
    },
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        dim_inactive = { enabled = true, percentage = 0.25 },
      },
    },
    {
      'sonph/onehalf',
      config = function(plugin)
        vim.opt.rtp:append(plugin.dir .. "/vim")
      end,
      enabled = false,
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = 'nvim-tree/nvim-web-devicons',
    },
    {
      'akinsho/bufferline.nvim',
      dependencies = 'nvim-tree/nvim-web-devicons',
      config = function()
        vim.schedule(function()
          require("bufferline").setup {
            options = {
              mode = 'tabs',
              max_name_length = 16,
              max_prefix_length = 12,
              numbers = 'ordinal',
              separator_style = 'slant',
              show_buffer_close_icons = false,
              show_duplicate_prefix = false,
              show_close_icon = false,
              diagnostics = "nvim_lsp",
              diagnostics_indicator = function(count, level)
                local icon = level:match("error") and " " or " "
                return " " .. icon .. count
              end
            },
          }
        end)
      end,
    },
    'akinsho/toggleterm.nvim',
    {
      "willothy/flatten.nvim",
      config = true,
      -- or pass configuration with
      -- opts = {  }
      -- Ensure that it runs first to minimize delay when opening file from terminal
      lazy = false,
      priority = 1001,
    },
    'numtoStr/Comment.nvim',
    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require('todo-comments').setup{}

        vim.keymap.set("n", "]t", function()
          require("todo-comments").jump_next()
        end, { desc = "Next todo comment" })

        vim.keymap.set("n", "[t", function()
          require("todo-comments").jump_prev()
        end, { desc = "Previous todo comment" })

        vim.keymap.set("n", "<leader>st", "<Cmd>TodoTelescope<CR>", { desc = "Search TODO comments" })
      end,
    },
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      opts = {
        -- add any options here
      },
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        "rcarriga/nvim-notify",
      }
    },
    {
      'kevinhwang91/nvim-ufo',
      dependencies = { 'kevinhwang91/promise-async' },
      config = function ()
        local handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = (' 󰁂 %d '):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, {chunkText, hlGroup})
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              -- str width returned from truncate() may less than 2nd argument, need padding
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, {suffix, 'MoreMsg'})
          return newVirtText
        end

        require('ufo').setup({
            fold_virt_text_handler = handler
        })

        vim.keymap.set('n', 'K', function()
          local winid = require('ufo').peekFoldedLinesUnderCursor()
          if not winid then
              vim.lsp.buf.hover()
          end
        end, { desc = 'ufo: Peek fold under cursor', noremap = true, silent = true, })
      end
    },
    {
      's1n7ax/nvim-window-picker',
      name = 'window-picker',
      event = 'VeryLazy',
      version = '2.*',
      config = function()
        local window_picker = require('window-picker')
        window_picker.setup {
          hint = 'floating-big-letter',
        }
        local pick = function()
          local wid = window_picker.pick_window()
          if wid ~= nil then
            vim.api.nvim_set_current_win(wid)
          else
            vim.notify('Window pick cancelled.', 'info')
          end
        end
        vim.keymap.set({ 'n' }, '<leader>wp', pick, {
          desc = "Window picker",
          noremap = true,
          silent = true,
        })
      end,
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      keys = {
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
    },
    {
      'folke/trouble.nvim',
      dependencies = 'nvim-tree/nvim-web-devicons',
      opts = {},
      cmd = "Trouble",
      keys = {
        {
          '<leader>tt',
          '<cmd>Trouble diagnostics toggle<cr>',
          desc = 'Diagnostics (Trouble)'
        },
        {
          '<leader>tT',
          '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
          desc = 'Buffer Diagnostics (Trouble)',
        },
        {
          '<leader>ts',
          '<cmd>Trouble symbols toggle focus=false<cr>',
          desc = 'Symbols (Trouble)',
        },
        {
          '<leader>tl',
          '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
          desc = 'LSP Definitions / references / ... (Trouble)',
        },
        {
          '<leader>tL',
          '<cmd>Trouble loclist toggle<cr>',
          desc = 'Location List (Trouble)',
        },
        {
          '<leader>tq',
          '<cmd>Trouble qflist toggle<cr>',
          desc = 'Quickfix List (Trouble)',
        },
      }
    },
    {
      'TimUntersberger/neogit',
      config = function()
        require('neogit').setup {
          graph_style = "unicode",
          disable_context_highlighting = true,
        }
        vim.keymap.set({ 'n' }, '<leader>gg', '<cmd>Neogit<CR>')
      end
    },

    -- Better move
    {
      'smoka7/hop.nvim',
      version = '2.*',
      config = function()
        require 'hop'.setup {}
      end
    },
    {
      "kylechui/nvim-surround",
      version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
          keymaps = {
            insert = "<C-`>s",
            insert_line = "<C-`>S",
            normal = "ys",
            normal_cur = "yss",
            normal_line = "yS",
            normal_cur_line = "ySS",
            visual = "S",
            visual_line = "gS",
            delete = "ds",
            change = "cs",
            change_line = "cS",
          },
        })
      end
    },
    -- Brackets
    {
      'windwp/nvim-autopairs',
      dependencies = { { 'hrsh7th/nvim-cmp' } },
      event = "InsertEnter",
      config = function()
        local npairs = require("nvim-autopairs")
        npairs.setup {
          check_ts = true,
        }

        local Rule = require("nvim-autopairs.rule")
        local cond = require('nvim-autopairs.conds')
        -- Before: {|}
        -- Input: <Space>
        -- After: { | }
        npairs.add_rules({
          Rule(" ", " "):with_pair(function(opts)
            local after_cond = cond.after_regex("[%}%]%)]")
            local before_cond = cond.before_regex("[%{%[%(]")
            return after_cond(opts) and before_cond(opts)
          end)
        })

        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        local cmp = require('cmp')
        cmp.event:on(
          'confirm_done',
          cmp_autopairs.on_confirm_done()
        )
      end,
    },
    'tpope/vim-unimpaired',
    -- Marker
    'kshenoy/vim-signature',

    -- Fuzzy finder
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        { 'nvim-lua/popup.nvim' },
        { 'nvim-lua/plenary.nvim' },
        { 'nvim-telescope/telescope-media-files.nvim' },
        { 'nvim-telescope/telescope-bibtex.nvim' },
        { 'nvim-telescope/telescope-symbols.nvim' },
      }
    },
    'tpope/vim-sleuth',

    -- Language supports
    -- Python utils // The indent really saved my life
    { 'Vimjas/vim-python-pep8-indent', ft = { 'python', } },
    { 'jmcantrell/vim-virtualenv',     ft = { 'python', } },
    -- Font-end tool chain
    { 'ap/vim-css-color',              ft = { 'css', 'less', 'scss', 'tsx', 'ts', 'vim', 'tmux', } },
    { 'maxmellon/vim-jsx-pretty',      ft = { 'tsx', 'jsx', } },
    'HerringtonDarkholme/yats.vim',
    'posva/vim-vue',
    -- Html preview
    { 'turbio/bracey.vim', ft = { 'html', } },
    -- Markdown syntax and preview
    'godlygeek/tabular',
    {
      'iamcco/markdown-preview.nvim',
      build = 'cd app && npx --yes yarn install',
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { 'markdown', 'vim-plug', }
    },
    -- Asm
    { 'Shirk/vim-gas',     ft = 'asm' },
    { 'cespare/vim-toml',  ft = { 'toml', } },

    -- Other utilities
    'mhinz/vim-rfc',
    'editorconfig/editorconfig-vim',
    'vim-scripts/Drawit',
    'voldikss/vim-translator',
    'jceb/vim-orgmode',
    'itchyny/calendar.vim',
    -- 'lilydjwg/fcitx.vim',
    {
      "folke/persistence.nvim",
      event = "BufReadPre", -- this will only start session saving when an actual file was opened
      config = function()
        require('persistence').setup {
          dir = vim.fn.stdpath("state") .. "/sessions/", -- directory where session files are saved
          -- minimum number of file buffers that need to be open to save
          -- Set to 0 to always save
          need = 1,
          branch = true, -- use git branch to save session
        }
        -- save the current session
        vim.keymap.set("n", "<leader>qs", function() require("persistence").save() end)
        -- select a session to load
        vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end)
        -- load the last session
        vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end)
        -- stop Persistence => session won't be saved on exit
        vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end)
      end,
    },
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      init = function()
        local snacks = require('snacks')
        vim.api.nvim_create_autocmd("User", {
          pattern = "VeryLazy",
          callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
              snacks.debug.inspect(...)
            end
            _G.bt = function()
              snacks.debug.backtrace()
            end
            vim.print = _G.dd -- Override print to use snacks for `:=` command

            -- Create some toggle mappings
            snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
            snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
            snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
            snacks.toggle.diagnostics():map("<leader>ud")
            snacks.toggle.line_number():map("<leader>ul")
            snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
            snacks.toggle.treesitter():map("<leader>uT")
            snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
            snacks.toggle.inlay_hints():map("<leader>uh")
            snacks.toggle.indent():map("<leader>ug")
            snacks.toggle.dim():map("<leader>uD")
          end,
        })
      end,
    }
  },

  install = { colorscheme = { 'onehalflight' } },
  checker = {
    enabled = true,
    concurrency = nil, ---@type number? set to 1 to check for updates very slowly
    notify = true,               -- get a notification when new updates are found
    frequency = 3600 * 24 * 7,   -- check for updates every hour
    check_pinned = false,        -- check for pinned packages that can't be updated
  },
})
