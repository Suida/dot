# agent-cockpit.nvim

Turn Neovim into an **agent team cockpit**: a persistent, role-based team of
CLI agents (kimi, codex, …) living in terminal buffers — orchestrated by a
main agent, operated hands-on by you, visible at a glance, and recoverable
across crashes and sessions.

Native subagent delegation is invisible, unsteerable, and dies with the
session. The cockpit replaces it with real CLI agent instances you can see,
interrupt, redirect, and resume.

## Concepts

- **Main agent** — the primary CLI agent (default `kimi`), auto-spawned at
  launch. It orchestrates the team through `agent-ctl` (on its PATH) and the
  companion workflow skill (`nvim-agent-orchestration`).
- **Team** — a persistent set of role-based members defined in
  `.agent/roster.md` (markdown table: role | cli | responsibilities), with
  per-role briefs at `.agent/roles/<role>.md` and status files at
  `.agent/status/<role>.md`.
- **Three zones** (left to right): collapsible explorer sidebar → review area
  (hidden by default; code inspection or the dashboard) → agent area.
- **Agent area modes** — Mode A: main agent holds the left 50%, team members
  stack as rows (≤3) or an auto-reflowing grid (>3) on the right. Mode B:
  main 50% + one focused member 50% in a fixed slot.

## Install

lazy.nvim, from a local checkout:

```lua
{
  dir = '/path/to/agent-cockpit.nvim',
  name = 'agent-cockpit',
  lazy = false,
  dependencies = { 'folke/snacks.nvim' },
  config = function() require('agent-cockpit').setup({}) end,
}
```

`setup()` options:

| opt | default | meaning |
|---|---|---|
| `main_agent` | `'kimi --yolo'` | CLI to auto-spawn as the main agent; `false` disables. Give the orchestrator autonomy flags — without them it stalls on approval prompts |
| `auto_recover` | `'ask'` | crash recovery: `'ask' \| 'always' \| 'never'` |
| `presets` | `{}` | user-layer keybinding presets (see below) |
| `prompt_delay` | `5000` | ms before a spawned member's initial prompt is typed (must cover slow TUI boots); submit is retried automatically |

The ready-made **profile** in `../nvim-agent/` launches a standalone cockpit
config: `NVIM_APPNAME=nvim-agent nvim`.

## Operating it

You (the operator) never need `agent-ctl` — everything has a command/keymap:

| Action | Command | Keymap |
|---|---|---|
| Worker picker | — | `<leader>a` |
| Explorer | — | `<leader>E` |
| Review area toggle | — | `<leader>r` |
| Dashboard toggle | `:AgentDashboard` | `<leader>d` |
| Layout mode A/B | `:AgentLayout [A\|B]` | `<leader>m` |
| Jump to member | `:AgentJump <id>` | `<A-1>`…`<A-9>` |
| Focus member (Mode B) | `:AgentFocus <id>` | — |
| Spawn / kill | `:AgentSpawn <id> [--cmd x] [--role r]` / `:AgentKill <id>` | — |
| Member diff | `:AgentDiff <id>` | — |
| Team | `:AgentTeamApply` / `:AgentTeamDump <n>` / `:AgentTeamRaise <n>` | — |
| Install bridge shim | `:AgentInstall [dir]` | — |

The main agent drives the same surface over `agent-ctl` (bash, PowerShell
`agent-ctl.ps1`, or the `agent-ctl.cmd` shim installed by `:AgentInstall`):
`spawn | focus | hide | kill | send | prompt | op | ops | send-keys | edit |
diff | list | status | layout | dashboard | team-apply | team-dump | team-raise`.

## File protocol (`.agent/`)

```
.agent/
├── nvim.sock        " RPC socket (Unix) / named-pipe pointer file (Windows)
├── session.json     " crash-recovery manifest (workers, layout, review area)
├── roster.md        " team definition (markdown table)
├── roles/<role>.md  " per-role briefs: responsibilities, scope, assignment
├── status/<role>.md " member-maintained: `state: working|blocked|done` + summary
└── presets.lua      " optional project-local keybinding preset overrides
```

Keybinding presets abstract each agent CLI's divergent keys into semantic ops
(`interrupt`, `submit`, `newline`); shipped presets cover kimi and codex,
layered under user config, project `.agent/presets.lua`, and per-spawn
overrides.

## Crash recovery

The manifest is rewritten on every registry/layout change. On a dirty exit,
relaunch offers to respawn every member — resuming each one's own CLI session
when the agent supports it (kimi `--session <id>`; codex falls back to
`codex resume --last`), restoring layout mode, focus, and review area.

## Tests

```bash
# unit (from any empty cwd)
nvim --headless -u NONE -l /path/to/agent-cockpit.nvim/tests/run.lua
# end-to-end (socket + bridges, real processes)
bash /path/to/agent-cockpit.nvim/tests/integration.sh
```
