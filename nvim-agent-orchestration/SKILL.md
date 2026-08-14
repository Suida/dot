---
name: nvim-agent-orchestration
description: Orchestrate worker CLI agents inside a Neovim cockpit. Use when running as the main agent in a project where Neovim was launched with the nvim-agent config (a `.agent/nvim.sock` exists or `agent-ctl` is on PATH) and work should be delegated to parallel CLI agents instead of native subagent tools.
---

# Agent Cockpit Orchestration

You hold the main-agent session of an agent-cockpit Neovim instance. You
orchestrate a persistent, role-based TEAM of CLI agents that live in terminal
buffers of this Neovim. The human operator watches the dashboard and can jump
into any member's terminal at any time.

`agent-ctl` works from any shell: a bash implementation, a native PowerShell
implementation (`agent-ctl.ps1`), and an `agent-ctl.cmd` shim all expose the
same commands, so if your shell is PowerShell (e.g. codex on Windows) the same
commands below work unchanged.

## Hard rules

- NEVER use native subagent / agent-swarm / Task tools. Delegate by spawning
  team members with `agent-ctl`.
- All coordination flows through you + files. There is no worker-to-worker
  channel. Artifacts go to the repo (`docs/`, code); state goes to
  `.agent/status/<role>.md`; assignments go to `.agent/roles/<role>.md`.
- On ANY new session, read `.agent/` first (roster.md, roles/, status/,
  session.json) before planning — a previous session's team may be on disk.

## Building the team

1. Understand the operator's goal and analyze the project.
2. Propose a roster: write `.agent/roster.md` as a markdown table
   (`| role | cli | responsibilities |`, one row per member; `main` is you —
   do not list it) and show it with `agent-ctl edit .agent/roster.md` so the
   operator can approve/edit it in the review area.
3. Once approved: `agent-ctl team-apply`. This scaffolds any missing role
   brief at `.agent/roles/<role>.md` and spawns each member with a prompt
   pointing at its brief. Flesh out each brief (scope, conventions, current
   assignment) before or right after applying.
4. Hidden/background members must run with autonomy flags
   (e.g. `kimi --auto`) or they stall on permission prompts — pass them via
   `--cmd`.

## Operating the team

- Poll `agent-ctl status <role>` or `agent-ctl list`; the operator sees the
  same states on the dashboard.
- Steer: `agent-ctl prompt <role> <text>`, `agent-ctl op <role> interrupt`.
- Reassign: edit `.agent/roles/<role>.md` (Current assignment) and prompt the
  member to re-read it.
- Layout: `agent-ctl layout A|B`, `agent-ctl focus <role>` (Mode B slot),
  `agent-ctl hide <role>`.
- A member showing `state: working` with no live process was interrupted —
  decide redo vs. continue from its status file, then respawn it
  (`agent-ctl spawn <role> --cmd <cli> --task .agent/roles/<role>.md`).

## Review flow

- When a member reports `state: done`: read its status file and artifacts,
  verify the work yourself, then post the operator a digest — what changed,
  where, what to check.
- Offer `agent-ctl diff <role>` when the operator wants the raw changes.

## Templates

- A roster worth keeping: `agent-ctl team-dump <name>`.
- New project, known shape: `agent-ctl team-raise <name>` (copies roster +
  briefs into `.agent/` and applies).

## agent-ctl reference

spawn <id> [--cmd cli] [--role r] [--task file] [--op k=v]... | focus <id> |
hide <id> | kill <id> | send <id> <text> | prompt <id> <text> | op <id> <name> |
ops <id> | send-keys <id> <keys> | edit <file> | diff <id> | list | status <id> |
layout [A|B] | dashboard | team-apply | team-dump <name> | team-raise <name>
