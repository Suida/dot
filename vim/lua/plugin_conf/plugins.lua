-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
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
      'mfussenegger/nvim-dap',
      {
        'nvimtools/none-ls.nvim',
        ft = { 'lua', 'python' },
      }
    },
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
    { 'suida/nvim-dap-lldb', dependencies = { "mfussenegger/nvim-dap" } },
    { 'mfussenegger/nvim-dap-python', dependencies = { "mfussenegger/nvim-dap" } },
    {
      "yetone/avante.nvim",
      event = "VeryLazy",
      lazy = false,
      version = false, -- set this if you want to always pull the latest change
      opts = {
        provider = "deepseek",
        vendors = {
          deepseek = {
            __inherited_from = "openai",
            api_key_name = "DEEPSEEK_API_KEY",
            endpoint = "https://api.deepseek.com",
            model = "deepseek-coder",
            timeout = 30000,
          },
        },
      },
      -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
      build = "make",
      -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        {
          -- support for image pasting
          "HakonHarnes/img-clip.nvim",
          event = "VeryLazy",
          opts = {
            -- recommended settings
            default = {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
              -- required for Windows users
              use_absolute_path = true,
            },
          },
        },
        {
          -- Make sure to set this up properly if you have lazy=true
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
      enabled = false,
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
      enabled = false,
      "Kurama622/llm.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", },
      cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler", },
      keys = {
        { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
        { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>" },
        { "<leader>ts", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
      },
    },
    {
      'glepnir/lspsaga.nvim',
      branch = 'main',
      event = 'LspAttach',
      config = function()
        ---@diagnostic disable-next-line: different-requires
        require('lspsaga').setup({
          beacon = {
            enable = false,
          },
        });
      end,
      dependencies = {
        { 'nvim-tree/nvim-web-devicons' },
        --Please make sure you install markdown and markdown_inline parser
        { 'nvim-treesitter/nvim-treesitter' }
      },
      enabled = false,
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

    -- Project-wide
    -- Git
    'tpope/vim-fugitive',
    'lewis6991/gitsigns.nvim',
    -- Global finder
    'brooth/far.vim',
    -- Session manager
    'mhinz/vim-startify',
    'stevearc/overseer.nvim',

    -- Outlook
    {
      'rose-pine/neovim',
      lazy = false,
      config = function ()
        vim.o.background = 'dark'
        vim.cmd('colorscheme rose-pine-moon')
      end
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
              max_name_length = 12,
              max_prefix_length = 10,
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
    'tomtom/tcomment_vim',
    {
      'stevearc/dressing.nvim',
      opts = {},
    },
    'rcarriga/nvim-notify',
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
    'nvim-tree/nvim-web-devicons',
    'nvim-tree/nvim-tree.lua',
    {
      'smoka7/hop.nvim',
      version = '2.*',
      config = function()
        require'hop'.setup {}
      end
    },
    -- 'andymass/vim-matchup',
    'tpope/vim-surround',
    -- Brackets
    {
      'windwp/nvim-autopairs',
      dependencies = { { 'hrsh7th/nvim-cmp' } },
      event = "InsertEnter",
      config = true
      -- use opts = {} for passing setup options
      -- this is equivalent to setup({}) function
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
    -- Indentation line
    'Yggdroot/indentLine',
    'tpope/vim-sleuth',

    -- Language supports
    -- Python utils // The indent really saved my life
    { 'Vimjas/vim-python-pep8-indent', ft = { 'python', } },
    { 'jmcantrell/vim-virtualenv', ft = { 'python', } },
    -- Font-end tool chain
    { 'ap/vim-css-color', ft = { 'css', 'less', 'scss', 'tsx', 'ts', 'vim', 'tmux', } },
    { 'maxmellon/vim-jsx-pretty', ft = { 'tsx', 'jsx', } },
    'HerringtonDarkholme/yats.vim',
    'posva/vim-vue',
    -- Pandoc
    'vim-pandoc/vim-pandoc',
    'vim-pandoc/vim-pandoc-syntax',
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
    { 'Shirk/vim-gas', ft = 'asm' },
    { 'cespare/vim-toml', ft = { 'toml', } },

    -- Other utilities
    'mhinz/vim-rfc',
    'editorconfig/editorconfig-vim',
    'vim-scripts/Drawit',
    'voldikss/vim-translator',
    'jceb/vim-orgmode',
    'itchyny/calendar.vim',
    'lilydjwg/fcitx.vim',
  },

  install = { colorscheme = { 'onehalflight' } },
  checker = {
    enabled = true,
    concurrency = nil, ---@type number? set to 1 to check for updates very slowly
    notify = true, -- get a notification when new updates are found
    frequency = 3600*24*7, -- check for updates every hour
    check_pinned = false, -- check for pinned packages that can't be updated
  },
})
