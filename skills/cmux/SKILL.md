---
name: cmux
description: "cmux CLI reference for Claude Code: workspace/pane/surface management, browser automation, multi-agent orchestration, sidebar metadata, notifications, and tmux migration. Use when running inside cmux terminal (CMUX_SOCKET_PATH is set)."
---

# cmux

## Detection Guard

Before using any cmux command, verify both conditions. If either fails, silently skip all cmux features.
```bash
[ -n "$CMUX_SOCKET_PATH" ] && command -v cmux >/dev/null 2>&1
```

## Hierarchy

```
Window > Workspace (sidebar tab) > Pane (split region) > Surface (terminal or browser tab)
```

- **Window** -- top-level macOS window
- **Workspace** -- sidebar tab (like a tmux session)
- **Pane** -- split container within a workspace
- **Surface** -- tab within a pane (terminal or browser)

**Handle format:** `window:1`, `workspace:2`, `pane:3`, `surface:4`
**ID output:** `--id-format refs|uuids|both` (default: `refs`)
**Environment variables (auto-set in cmux terminals):**

| Variable | Purpose |
|----------|---------|
| `CMUX_WORKSPACE_ID` | Current workspace UUID |
| `CMUX_SURFACE_ID` | Current surface UUID |
| `CMUX_SOCKET_PATH` | Control socket path |

Commands default to the current workspace/surface when `--workspace` or `--surface` flags are omitted.

## Quick Reference

| Command | Syntax | Purpose |
|---------|--------|---------|
| identify | `cmux identify` | Current context (JSON) |
| tree | `cmux tree [--all]` | Full hierarchy tree |
| new-workspace | `cmux new-workspace [--name N] [--cwd P] [--command C]` | Create workspace |
| new-split | `cmux new-split <left\|right\|up\|down> [--surface S]` | Split pane |
| send | `cmux send --surface S "text\n"` | Send text to surface (`\n` = Enter) |
| send-key | `cmux send-key --surface S <key>` | Send key (enter, ctrl+c, tab) |
| read-screen | `cmux read-screen [--surface S] [--lines N] [--scrollback]` | Read terminal output |
| capture-pane | `cmux capture-pane [--surface S]` | Alias for read-screen |
| notify | `cmux notify --title T --body B` | In-app notification |
| set-status | `cmux set-status <key> <value> [--icon I] [--color C]` | Sidebar status pill |
| set-progress | `cmux set-progress <0.0-1.0> [--label L]` | Sidebar progress bar |
| log | `cmux log --level <info\|success\|warning\|error> -- "msg"` | Sidebar log entry |
| browser open | `cmux browser open <url>` | Open browser split |
| browser snapshot | `cmux browser [S] snapshot --interactive` | DOM snapshot with element refs |
| browser click | `cmux browser [S] click <ref>` | Click element |
| browser fill | `cmux browser [S] fill <ref> "text"` | Fill input field |
| browser wait | `cmux browser [S] wait --load-state complete` | Wait for page load |
| wait-for | `cmux wait-for <name> [--timeout N]` | Wait for signal |
| rename-workspace | `cmux rename-workspace "name"` | Rename current workspace |
| close-surface | `cmux close-surface --surface S` | Close a surface |

## Deep-Dive References

Load these only when you need detailed syntax or advanced patterns:

| Reference | When to load | Path |
|-----------|-------------|------|
| Complete CLI | Need full command syntax or flags | `references/complete-cli.md` |
| Browser Automation | Automating browser surfaces | `references/browser-automation.md` |
| Multi-Agent Orchestration | Spawning/coordinating agents in panes | `references/orchestration.md` |
| Notifications | Choosing notification strategy | `references/notifications.md` |

## Restraint Guidelines

- **Workspaces:** Create new workspaces only for genuinely isolated parallel work (separate project roots). Default to `new-split` within the current workspace.
- **Browser splits:** Open only for visual/DOM verification needs. Close the browser surface when done.
- **Progress bar:** Use `set-progress` only for tasks exceeding ~30 seconds. Clear when done.
- **Notifications:** Use `notify` only at genuine handoff points (task complete, approval needed). Do not spam.
- **Best-effort calls:** All cmux commands are best-effort. Redirect stderr to `/dev/null` and never let a cmux failure block your primary task.

```bash
cmux set-progress 0.5 --label "building" 2>/dev/null || true
```

## tmux Migration

| tmux | cmux | Notes |
|------|------|-------|
| `new-session -d -s N` | `new-workspace --name N` | Workspace = session |
| `split-window -v` | `new-split down` | Vertical split |
| `split-window -h` | `new-split right` | Horizontal split |
| `send-keys -t P "cmd" C-m` | `send --surface P "cmd\n"` | `\n` sends Enter |
| `send-keys -t P C-c` | `send-key --surface P ctrl+c` | Control keys via send-key |
| `capture-pane -t P -p` | `capture-pane --surface P` | Same name, different flags |
| `capture-pane -p -S -` | `read-screen --scrollback` | Full scrollback |
| `kill-session -t N` | `close-workspace --workspace N` | |
| `kill-pane -t P` | `close-surface --surface S` | Surfaces, not panes |
| `wait-for ch` | `wait-for ch [--timeout 30]` | Optional timeout |
| `wait-for -S ch` | `wait-for --signal ch` | Signal (send) |
| `pipe-pane "cmd"` | `pipe-pane --command "cmd"` | |
| `resize-pane -L/-R/-U/-D N` | `resize-pane --pane P -L\|-R\|-U\|-D [--amount N]` | |
| `swap-pane -t T` | `swap-pane --pane P --target-pane T` | |
| `break-pane` | `break-pane [--pane P]` | |
| `join-pane -t T` | `join-pane --target-pane T` | |
| `select-window -n/-p/-l` | `next-window` / `previous-window` / `last-window` | |
| `last-pane` | `last-pane` | |
| `clear-history` | `clear-history [--surface S]` | |
| `set-buffer` / `paste-buffer` | `set-buffer [--name N] <text>` / `paste-buffer [--name N]` | Named buffers |
| `respawn-pane` | `respawn-pane [--surface S] [--command C]` | |
| `display-message -p "text"` | `display-message [-p] <text>` | |
| _(no equivalent)_ | `browser`, `notify`, `set-status`, `set-progress`, `log`, `rename-tab` | cmux-only features |
