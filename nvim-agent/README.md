# nvim-agent

A minimal Neovim config that turns the editor into an agent cockpit: a main CLI
agent orchestrates worker CLI agents living in terminal buffers, via the
`agent-ctl` bridge. See `docs/superpowers/specs/2026-08-12-nvim-agent-cockpit-design.md`.

## Launch

```bash
NVIM_APPNAME=nvim-agent nvim
```

First launch clones lazy.nvim + snacks.nvim. The config listens on
`<cwd>/.agent/nvim.sock`; put `nvim-agent/bin` on PATH (or symlink `agent-ctl`)
so agents can drive it from any subdirectory.

## Human keymaps

- `<leader>a` — worker picker (focus / `<M-h>` hide / `<M-k>` kill)
- `<M-Backspace>` — toggle last worker pane
- `<A-1..9>` — focus worker by index
- `<leader>E` — file explorer

## Demo (no real agents needed)

```bash
NVIM_APPNAME=nvim-agent nvim          # in a scratch dir, then in another shell:
agent-ctl spawn w1 --cmd "bash <repo>/nvim-agent/tests/fake-agent.sh .agent/status/w1.md"
agent-ctl focus w1
agent-ctl prompt w1 "mark DONE when ready"
agent-ctl status w1                   # -> state: done
agent-ctl kill w1
```

With real agents: `agent-ctl spawn w1 --cmd kimi --task .agent/tasks/w1.md`.

## Crash recovery

State lives in `.agent/session.json`. After a crash, relaunching offers to
respawn workers — with the preset's `resume` command when defined
(`kimi --continue`, `codex resume --last`), otherwise fresh with a crash note.
Configure: `require('agent').setup({ auto_recover = 'always' })` (or `'never'`).

## Windows notes

- On Windows, `.agent/nvim.sock` is not a socket: it is a plain-text pointer
  file containing the named-pipe address the instance actually listens on.
  Clients (including `agent-ctl`) read it to discover the address — do not
  treat it as a socket file.
- Headless/background Neovim instances on Windows need a console attached:
  ConPTY gives terminal jobs instant EOF without one, so worker terminals die
  immediately. Real TUI usage (launching nvim in a terminal window) is
  unaffected.

## Tests

```bash
cd $(mktemp -d) && nvim --headless -u NONE -l <repo>/nvim-agent/tests/run.lua
bash <repo>/nvim-agent/tests/integration.sh
```
