---
name: nvim-agent-orchestration
description: Orchestrate worker CLI agents inside a Neovim cockpit. Use when running as the main agent in a project where Neovim was launched with the nvim-agent config (a `.agent/nvim.sock` exists or `agent-ctl` is on PATH) and work should be delegated to parallel CLI agents instead of native subagent tools.
---

# nvim-agent Orchestration

You are the **main agent** in a Neovim agent cockpit. Delegate work to worker CLI
agents that live in Neovim terminal buffers. **Do not use your native subagent /
task / swarm tools** — workers are spawned, steered, and harvested exclusively
through the `agent-ctl` command and files under `.agent/`.

`agent-ctl` works from any shell: on Windows an `agent-ctl.cmd` shim sits next to
the bash implementation, so if your shell is PowerShell (e.g. codex on Windows)
the same commands below work unchanged. If `agent-ctl` is not found, fall back
to `bash agent-ctl ...`.

## Session start protocol

Before planning anything, check for existing state:

```bash
ls .agent/tasks/ .agent/status/ 2>/dev/null
agent-ctl list
```

If tasks/status exist, read them first. A worker whose status file says
`state: working` but which `agent-ctl list` reports as not alive was interrupted —
decide from its status file whether to respawn it or continue its work yourself.

## Delegating a task

1. Pick a short worker id (e.g. `w1`, `docs`, `fix-auth`).
2. Write `.agent/tasks/<id>.md`:

```markdown
# Task: <short title>
- Worker: <id>
- Goal: <what to achieve>
- Scope: <files/dirs in scope; what NOT to touch>
- Done criteria: <verifiable end state>
- Pointers: <relevant files/docs>
```

3. Spawn the worker (hidden, runs in background). Always give workers their
   CLI's autonomous/auto-approve flag — a hidden worker cannot ask the human
   for tool approvals and will silently stall on a permission prompt:

```bash
agent-ctl spawn <id> --cmd 'kimi --auto'   --task .agent/tasks/<id>.md
agent-ctl spawn <id> --cmd codex  --task .agent/tasks/<id>.md
```

4. Show it to the human when useful: `agent-ctl focus <id>`; put it back with
   `agent-ctl hide <id>`.
5. Open files in the main editor pane for the human: `agent-ctl edit <file>`.

## Monitoring

Workers maintain `.agent/status/<id>.md`:

```markdown
state: working | blocked | done
<summary line — shown in picker and `agent-ctl list`>

<running notes; final result and pointers to produced files when done>
```

Poll with `agent-ctl status <id>` (or `agent-ctl list` for all). Never scrape
terminal output — the status file is the contract.

## Steering a live worker

Use semantic operations — never raw key sequences:

```bash
agent-ctl prompt <id> "clarification or new instruction"   # text + submit
agent-ctl op <id> interrupt                                # stop current action
agent-ctl op <id> newline                                  # insert newline
agent-ctl ops <id>                                         # list available ops
agent-ctl send <id> "literal text, no submit"
```

`send-keys` exists as an escape hatch but prefer `op`/`prompt`.

## Finishing

When a worker reports `state: done`, read its status file and result docs, verify
the done criteria, then `agent-ctl kill <id>`.

## If you are a worker

If your initial prompt points at `.agent/tasks/<id>.md`, you are a worker:
read the task file, keep `.agent/status/<id>.md` current (first line
`state: working|blocked|done`), write results to the files the task names, and
finish with `state: done` plus a summary and file pointers. If a crash-recovery
note says to continue, read your status file before doing anything else.
