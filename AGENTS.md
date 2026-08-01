# AGENTS.md

A cross-platform (Windows / WSL / Linux) dotfiles collection. The Neovim
configuration under `vim/` is the primary and most complex component; the rest
is terminal/shell/editor/Git config deployed via symlinks.

There is **no build system, test suite, or CI**. "Installing" a component means
symlinking its file(s) into the target application's config path (commands are
documented in `README.md`). A few subdirectories ship Python install scripts
that perform the symlinking programmatically (`tmux/build.py`, `db/install.py`).

## Neovim architecture (the part that bites)

### Wiring model — read this before editing any plugin config

Plugin specs live in `vim/lua/plugin_conf/plugins.lua` (a `lazy.nvim` `spec`).
Plugin *configuration* is split into separate `vim/lua/plugin_conf/<name>.lua`
modules, which are loaded by **explicit `require` calls in `vim/init.lua`**.

```
vim/init.lua
  ├── require 'plugin_conf.plugins'        ← lazy.nvim spec (bootstraps lazy.nvim itself)
  ├── require 'plugin_conf.snacks-conf'
  ├── require 'plugin_conf.mason'
  ├── ... (explicit list of ~25 modules)
  └── require 'ftdetect'
```

**Critical gotcha:** the `require` list in `init.lua` is the single source of
truth for what is actually loaded. The directory `vim/lua/plugin_conf/`
contains several files that are **never required** and reference plugins that
are **no longer in the `plugins.lua` spec**. Editing these dead files has zero
effect. Known dead/orphaned configs (verify before relying on this list):

| File | Status |
| --- | --- |
| `plugin_conf/nvim-tree.lua` + `nvim-tree-on-attach.lua` | nvim-tree not in spec; explorer replaced by `snacks.explorer` |
| `plugin_conf/lspsaga.lua` | lspsaga not in spec; not required |
| `plugin_conf/startify.lua` | vim-startify not in spec; dashboard replaced by `snacks.dashboard` |
| `plugin_conf/easymotion.lua` | easymotion not in spec; replaced by `hop.nvim` (`hop_conf.lua`) |
| `plugin_conf/llm_ds.lua` | llm.nvim not in spec; replaced by codecompanion/avante/minuet |
| `plugin_conf/pandoc.lua` | not required by `init.lua` (standalone conceal autocmd) |
| `after/ftplugin/markdown.lua` | empty file |

When adding a new plugin: add the spec to `plugins.lua`, create the config in
`plugin_conf/<name>.lua`, **and add the `require` line to `init.lua`** —
otherwise the config never runs.

### Convention for every `plugin_conf/*.lua` module

Each module guards its require with `pcall` and bails early if the plugin isn't
present (so config can be sourced even when a plugin fails to install):

```lua
local status_ok, plugin = pcall(require, 'plugin')
if not status_ok then
  return
end
```

Follow this pattern for any new plugin config module.

### Shared utilities — `vim/lua/user/utils.lua`

Returns a table `M` (note: it's a global-style module, not using `local M = {}`
at the top — `M` is assigned directly). Functions used across the config:

- `get_os_type()` → `'unix'` or `'win32'` (based on `package.config:sub(1,1)`).
  **Use this for any cross-platform branching**, not `vim.fn.has('win32')`.
- `append_slash(path)` → appends the OS-correct separator.
- `get_tab_width()` / `get_tab_height()` → right/bottom-most non-floating win
  position + size; used for toggleterm sizing and nvim-tree float geometry.
- `detect_windows_theme(cb)` → async via `vim.loop` + `pwsh.exe` reading the
  Windows registry `AppsUseLightTheme`; calls back with `'dark'`/`'light'`.
- `auto_color_config(light, dark)` / `get_class_or_method_name()` (treesitter,
  used by the pytest DAP config to prefill `-k`).

`vim/lua/user/autocolor.lua` wraps `detect_windows_theme` into a polling loop
(`vim.defer_fn`, 1s then every 10s) that re-applies `rose-pine-moon` /
`rose-pine-dawn` when the OS theme flips. `wezterm.lua` mirrors the same
rose-pine theme switching via `update-right-status`.

### Legacy Vimscript layer

`init.lua` sources two Vimscript files from `vim/vim_scripts/`:
- `config.vim` — basic options (`set` commands), persistent undo setup, WSL
  `win32yank` clipboard config (`has('win32') && has('unix')` branch).
- `general_mappings.vim` — global keymaps (leader-based buffer/tab/window nav,
  Emacs-style cmdline bindings, `jk`/`JK`/`Jk` → `<C-\><C-n>` to exit
  insert/terminal mode, `iabbrev` for email/copyright).

These are plain Vimscript and are `vim.cmd('source ...')`'d, not required as
Lua modules. Edit them in Vimscript.

### Plugin pinning

`vim/lazy-lock.json` pins every plugin to an exact commit. `plugins.lua`
configures `checker` to look for updates weekly. The `install` fallback
colorscheme is `onehalflight` (note: the `onehalf` plugin spec has
`enabled = false`).

## Environment variables the config depends on

| Variable | Used by | Purpose |
| --- | --- | --- |
| `DEEPSEEK_API_KEY` | avante, codecompanion, minuet | DeepSeek API auth |
| `DASHSCOPE_API_KEY` | avante (bailian), codecompanion (qwen), minuet (qwen) | Alibaba Qwen/DashScope auth |
| `ZK_NOTEBOOK_DIR` | telekasten, overseer pandoc templates | Zettelkasten notebook root; pandoc build templates only register when `$ZK_NOTEBOOK_DIR/scripts/build.py` exists |
| `PYENV_ROOT` | `init.lua` (python3 host prog on Windows) | Neovim python provider path |

The AI stack runs three overlapping plugins simultaneously —
`codecompanion` (`<leader>an` chat / `<leader>ap` toggle / `<leader>al`
actions), `avante.nvim` (`<A-a>` toggle), and `minuet-ai` (`<A-y>` in `cmp`).
`plugin_conf/codecompanion-notify.lua` drives a spinner notification off
`CodeCompanionRequestStarted`/`Finished` `User` autocmds.

## Keymap precedence and conflicts

Because configs are required in a fixed order in `init.lua`, later `vim.keymap.set`
calls win. Notable overlaps an agent should be aware of:

- **LSP navigation:** `lspconfig.lua` binds `gs`, `<leader>wa/wr/wl/D/rn/ca/ft`,
  `[d`/`]d`, `<leader>q`. `snacks-conf.lua` (required later) binds `gd`/`gD`/
  `gr`/`gi`/`gy` to `snacks.picker.lsp_*` — so LSP go-to-def/references route
  through the snacks picker, **not** the default vim.lsp handlers. The orphaned
  `lspsaga.lua` also binds `gd`/`gr`/`K`/`gh`/`gp` but is never loaded.
- **`<leader>gl`:** bound by both `toggleterm.lua` (lazygit float) and
  `snacks-conf.lua` (git log). snacks wins (required later). Use `<leader>gg`
  for neogit, and note lazygit is effectively shadowed.
- **`K`:** `nvim-ufo` config (in `plugins.lua`) binds `K` to peek-fold-or-hover;
  the orphaned `lspsaga.lua` also binds `K` but is not loaded.
- **DAP F-keys:** `dap.lua` binds both `<S-F5>`/`<F17>` (disconnect) and
  `<S-F11>`/`<F23>` (step out) because WezTerm translates Shift-F5 → F17 and
  Shift-F11 → F23. Keep both forms if editing DAP keys.
- **`<leader>e`:** bound by `snacks-conf.lua` (explorer) and the orphaned
  `nvim-tree.lua`. snacks wins.

Leader is `<space>` (`vim.g.mapleader`); local leader is `\`.
`jk` exits terminal/insert mode (mapped in `init.lua` and `general_mappings.vim`).

## DAP / debugging specifics

`dap.lua` + `plugin_conf/dap-python.lua` + `dap-lldb` (in spec):

- C/C++: `gdb-oneapi` adapter (`gdb-oneapi -i dap`) plus `dap-lldb`. Launch
  config prompts for executable path, defaults to `cwd/`.
- Python: `debugpy` via `python -m debugpy.adapter`. Three configs:
  1. "Debug pytest expression" — prefill comes from
     `user.utils.get_class_or_method_name()` (treesitter walk for
     `function_definition`/`function_declaration`/`method_definition`).
  2. "Debug pytest for a file" — `${file}`.
  3. "Run current file" — args gathered via `snacks.input` inside a
     **coroutine** (`coroutine.create` + `coroutine.resume`); don't "simplify"
     this to a sync `vim.fn.input` — dap expects the args function to resume
     the coroutine.
- `dapui` opens on attach/launch, closes on `event_terminated`/`event_exited`.

## Completion (`cmp-conf.lua`)

`<C-f>` confirms (`select = true`); `<Tab>`/`<S-Tab>` cycle entries **and** jump
LuaSnip placeholders; `<C-Space>` manual complete; `<A-y>` triggers minuet AI.
`keyword_length = 3`. `ghost_text` is **off** because it conflicts with
copilot.vim's inline preview (copilot is bound to `<C-f>` accept, `<M-n>`/`<M-p>`
cycle, `copilot_no_tab_map = true`).

Filetype-specific sources: `markdown` adds `pandoc_references`; `gitcommit`
adds `cmp_git`. Cmdline `/`/`?` use `buffer`; `:` uses `path`+`cmdline`; both
with `autocomplete = false`.

LuaSnip custom snippets (`vim/lua/user/my_snippets.lua`) are registered for
`c`, `cpp`, `pandoc`, `systemverilog` (header guards, if/elif, katex blocks,
verilog module/timescale). `vim-snippets` (snipmate) is also lazy-loaded.

## LSP servers (`lspconfig.lua` + `lsp-python.lua`)

`clangd` runs with `--header-insertion=never`. `verible-verilog-ls` runs with a
custom `--rules` disable list. `texlab` builds via `tectonic` and does
SyncTeX forward search through a custom `evince-synctex.sh` (path is hardcoded
to `~/workspace/github/evince-synctex/`). `lua_ls` is told `vim` is a global
and uses `~/.cache/lua-language-server/meta/` as metapath. Python runs
**pyright + ruff** together; an `LspAttach` autocmd disables ruff's
`hoverProvider` so pyright handles hover (see `lsp-python.lua`).

`mason.lua` intentionally does **not** call `mason_lsp.setup{}` (commented out
— it double-starts servers). `.luarc.json` declares `vim` and `get_os_type` as
globals for `lua-language-server` diagnostics in this repo.

## Filetype detection

`vim/lua/ftdetect.lua` registers: `*.do` and `*.xdc` → `tcl`; `*.vh` →
`verilog`. `after/ftplugin/cpp.lua` sets 2-space indent; `after/ftplugin/html.vim`
sets 2-space indent. (`after/ftplugin/markdown.lua` is empty.)

## Colorscheme

Active: **rose-pine** (`rose-pine-moon` dark / `rose-pine-dawn` light), set in
`plugins.lua`. `catppuccin` is also installed but not applied. `onehalf` is
disabled. The dark/light choice is driven by `autocolor.lua` polling the
Windows theme on a timer (see "Shared utilities"). On non-Windows the dark
scheme is the static default.

## Other repo components (non-Neovim)

- `git/gitconfig` — user `harass` / `suidar@foxmail.com`, `editor = nvim`,
  `autocrlf = input`, nvimdiff as diff/merge tool, `safe.directory = *`,
  `init.defaultBranch = master`. `gitconfig.gui` is the same but with
  `nvim-qt` as editor/difftool.
- `tmux/` — `tmux.conf` (prefix `C-s`, vi mode, `h/j/k/l` pane nav,
  `win32yank.exe` copy, tpm plugins) + `hugh.tmux` theme + `build.py` installer
  (symlinks config, clones tpm).
- `zsh/` — oh-my-zsh `intheloop` theme, plugin list, `EDITOR=nvim`, fnm/cargo/
  coursier/uv setup, exa/fdfind aliases, chpwd hook sourcing
  `.zsh-chpwd-hook`, and `~/.local_conf.sh` for machine-specific config (see
  `local_conf_example.sh` for a Manjaro/pyenv/llvm/vcpkg/vivado example).
  `zprofile` runs `pyenv init --path`.
- `wezterm/wezterm.lua` — Lua config; rose-pine auto-switch via
  `update-right-status`; LEADER key; tab title formatting strips `.exe`/`.EXE`.
- `alacritty/` — `alacritty.windows.yml` (imports a themes yaml that may not
  exist — path `~/.config/alaritty/themes/...` has a typo `alaritty` vs
  `alacritty`) and `alacritty.yml` / `.windows.toml` variants.
- `powershell/Microsoft.PowerShell_profile.ps1` — starship prompt,
  `Get-ChildItemColor`, aliases (`~`, `..`, `ll`, `touch`, `which`, `g`, `gst`,
  `v` = nvim-qt), Emacs PSReadLine mode + history prediction, Chocolatey,
  `arch` function launching WSL archlinux, `$BAT_THEME="GitHub"`.
- `windows-terminal/` — `settings.json` + `Febby-settings.json` variant.
- `vscode/` — `settings.json`, `keybindings.json`, `vscode_plugins.txt`.
- `db/` — Python scripts to create MySQL/PostgreSQL/Redis Docker containers
  and install mycli/pgcli/rdcli clients; `install.py` orchestrates; `README.md`
  documents the `docker run` commands and client install steps.
- `project_files/` — `tsconfig.json` (umi.js `@/`/`@@/` path aliases),
  `jsconfig.json`, `ycm_extra_conf.py` (legacy YouCompleteMe cfamily flags +
  vue vetur config — predates the lspconfig setup).
- `libinput/libinput-gestures.conf` — touchpad swipe gestures.
- `scripts/portproxy.ps1` — WSL2 port forwarding + firewall rules.
- `aura.ahk` — AutoHotkey key remaps (Caps→RCtrl, AppsKey combos).
- `Makefile` — legacy Ubuntu apt helpers (Tsinghua mirror switch, dev util
  install, zsh/ohmyzsh). `37req.txt` and `baseline.txt` are stale pip/apt
  requirement snapshots.

## Style / conventions

- `.editorconfig`: LF endings, UTF-8, final newline; **2-space indent for
  `.lua` and `.py`**. (Vim's own `config.vim` sets `tabstop=4`/`shiftwidth=4`
  with `expandtab`, and `init.lua` overrides to 2 for JS/TS/CSS/HTML/Vue and 4
  for verilog.)
- Lua modules return a table `M`; the `pcall`-guard header is universal in
  `plugin_conf/`.
- Commit messages use **gitmoji prefixes** (`✨` feature, `🐛` fix) with a
  short imperative subject, e.g. `✨ Steal many interesting features from
  AstroNvim`.
- `.gitignore` excludes swap files, `vim/plugin`, `tags`, `vim/undo/`,
  `__pycache__`, `.bitfun/`. `.gitmodules` is empty (submodules were removed
  when the config moved to lazy.nvim).
