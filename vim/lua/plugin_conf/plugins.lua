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
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
      {
        'nvimtools/none-ls.nvim',
        ft = { 'lua', 'python' },
      }
    },
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
    { 'julianolf/nvim-dap-lldb', dependencies = { "mfussenegger/nvim-dap" } },
    { 'mfussenegger/nvim-dap-python', dependencies = { "mfussenegger/nvim-dap" } },
    { 'github/copilot.vim' },
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
      -- opts = function()
      --   local metals_config = require("metals").bare_config()
      --   metals_config.on_attach = function(client, bufnr)
      --     -- your on_attach function
      --   end
      --
      --   return metals_config
      -- end,
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
  --
  --   -- Outlook
    {
      'rose-pine/neovim',
      lazy = false,
      config = function ()
        require('user.utils').auto_color_config('rose-pine-dawn', 'rose-pine-moon');
      end
    },
    {
      'sonph/onehalf',
      config = function(plugin)
        vim.opt.rtp:append(plugin.dir .. "/vim")
        require('user.utils').auto_color_config('onehalfdark', 'onehalflight');
      end,
      enabled = false,
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = 'nvim-tree/nvim-web-devicons',
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
