# Complete cmux CLI Reference

Exhaustive command catalog verified against cmux v0.63.1 (2026-03-31).

Handles accept short refs (`window:1`, `workspace:2`, `pane:3`, `surface:4`), UUIDs, or numeric indexes. Environment variables `CMUX_WORKSPACE_ID`, `CMUX_SURFACE_ID`, `CMUX_SOCKET_PATH` auto-set in cmux terminals allow omitting `--workspace`/`--surface` flags.

---

## 1. System & Meta

| Command | Syntax | Purpose |
|---------|--------|---------|
| identify | `cmux identify [--json] [--workspace W] [--surface S] [--no-caller]` | Print server identity and caller context |
| tree | `cmux tree [--all] [--workspace W] [--json]` | Print hierarchy of windows/workspaces/panes/surfaces |
| ping | `cmux ping` | Check socket connectivity |
| capabilities | `cmux capabilities` | Print server capabilities as JSON (methods, protocol, access mode) |
| version | `cmux version` | Print version string |
| welcome | `cmux welcome` | Show welcome screen |
| shortcuts | `cmux shortcuts` | Open keyboard shortcuts settings |
| themes | `cmux themes list\|set\|clear` | Theme management (list available, set, or clear theme) |
| feedback | `cmux feedback [--email E --body B [--image P ...]]` | Submit feedback |

## 2. Window Management

| Command | Syntax | Purpose |
|---------|--------|---------|
| list-windows | `cmux list-windows` | List open windows |
| current-window | `cmux current-window` | Print current window ID |
| new-window | `cmux new-window` | Create new window |
| focus-window | `cmux focus-window --window W` | Focus (bring to front) a window |
| close-window | `cmux close-window --window W` | Close a window |

## 3. Workspace Management

| Command | Syntax | Purpose |
|---------|--------|---------|
| list-workspaces | `cmux list-workspaces` | List workspaces in current window |
| current-workspace | `cmux current-workspace` | Print current workspace ID |
| new-workspace | `cmux new-workspace [--cwd P] [--command T] [--name N]` | Create workspace with optional cwd, startup command, and name |
| select-workspace | `cmux select-workspace --workspace W` | Switch to workspace |
| rename-workspace | `cmux rename-workspace [--workspace W] <title>` | Rename workspace (alias: `rename-window`) |
| close-workspace | `cmux close-workspace --workspace W` | Close workspace |
| reorder-workspace | `cmux reorder-workspace [--workspace W] [--index N \| --before W \| --after W]` | Reorder workspace within window |
| move-workspace-to-window | `cmux move-workspace-to-window --workspace W --window W` | Move workspace to a different window |
| workspace-action | `cmux workspace-action --action A [--workspace W] [--color C]` | Context-menu actions: pin, unpin, rename, clear-name, move-up, move-down, move-top, close-others, close-above, close-below, mark-read, mark-unread, set-color, clear-color |
| next-window | `cmux next-window` | Select next workspace |
| previous-window | `cmux previous-window` | Select previous workspace |
| last-window | `cmux last-window` | Select last-used workspace |

**Named colors for `--color` (16):** Red, Crimson, Orange, Amber, Olive, Green, Teal, Aqua, Blue, Navy, Indigo, Purple, Magenta, Rose, Brown, Charcoal. Hex values also accepted (e.g. `#C0392B`).

## 4. Pane Management

| Command | Syntax | Purpose |
|---------|--------|---------|
| list-panes | `cmux list-panes [--workspace W]` | List panes in workspace |
| new-split | `cmux new-split <left\|right\|up\|down> [--workspace W] [--surface S]` | Split current pane in given direction |
| new-pane | `cmux new-pane [--type terminal\|browser] [--direction left\|right\|up\|down] [--workspace W] [--url U]` | Create new pane with type, direction, and optional URL |
| focus-pane | `cmux focus-pane [--pane P] [--workspace W]` | Focus a pane |
| resize-pane | `cmux resize-pane [--pane P] [-L \| -R \| -U \| -D] [--amount N]` | Resize pane in direction (default: -R, amount 1) |
| swap-pane | `cmux swap-pane --pane P --target-pane P` | Swap two panes |
| break-pane | `cmux break-pane [--pane P] [--surface S] [--no-focus]` | Break surface out into its own pane |
| join-pane | `cmux join-pane --target-pane P [--pane P] [--surface S] [--no-focus]` | Join pane/surface into another pane |
| last-pane | `cmux last-pane [--workspace W]` | Focus previously focused pane |

## 5. Surface Management

| Command | Syntax | Purpose |
|---------|--------|---------|
| new-surface | `cmux new-surface [--type terminal\|browser] [--pane P] [--workspace W] [--url U]` | Create new surface (tab) in pane |
| close-surface | `cmux close-surface [--surface S] [--workspace W]` | Close a surface |
| list-pane-surfaces | `cmux list-pane-surfaces [--workspace W] [--pane P]` | List surfaces in a pane |
| list-panels | `cmux list-panels [--workspace W]` | List all surfaces (panels) in workspace |
| focus-panel | `cmux focus-panel --panel P [--workspace W]` | Focus a surface by panel ref |
| move-surface | `cmux move-surface [--surface S] [--pane P \| --workspace W \| --window W] [--before R \| --after R \| --index N]` | Move surface to different pane/workspace/window |
| reorder-surface | `cmux reorder-surface [--surface S] [--before R \| --after R \| --index N]` | Reorder surface within its pane |
| drag-surface-to-split | `cmux drag-surface-to-split --surface S <left\|right\|up\|down>` | Move surface into a new split in given direction |
| rename-tab | `cmux rename-tab [--surface S] <title>` | Rename a surface tab |
| trigger-flash | `cmux trigger-flash [--surface S]` | Flash unread indicator on surface |
| refresh-surfaces | `cmux refresh-surfaces` | Refresh all surface snapshots |
| surface-health | `cmux surface-health [--workspace W]` | Health details for surfaces in workspace |
| tab-action | `cmux tab-action --action A [--tab R]` | Tab actions: rename, clear-name, close-left, close-right, close-others, new-terminal-right, new-browser-right, reload, duplicate, pin, unpin, mark-read, mark-unread |

## 6. Terminal I/O

| Command | Syntax | Purpose |
|---------|--------|---------|
| send | `cmux send [--surface S] <text>` | Send text to terminal (`\n` = Enter, `\t` = Tab) |
| send-key | `cmux send-key [--surface S] <key>` | Send key event (enter, ctrl+c, tab, etc.) |
| send-panel | `cmux send-panel --panel P <text>` | Send text to specific panel |
| send-key-panel | `cmux send-key-panel --panel P <key>` | Send key to specific panel |
| read-screen | `cmux read-screen [--surface S] [--scrollback] [--lines N]` | Read terminal screen text |
| capture-pane | `cmux capture-pane [--surface S] [--scrollback] [--lines N]` | Alias for read-screen (tmux compat) |
| pipe-pane | `cmux pipe-pane [--surface S] [--command C]` | Pipe terminal output to shell command |
| clear-history | `cmux clear-history [--surface S]` | Clear scrollback history |
| respawn-pane | `cmux respawn-pane [--surface S] [--command C]` | Restart shell or run command in surface |
| display-message | `cmux display-message [-p] <text>` | Display a message (tmux compat) |

## 7. Sidebar Metadata

| Command | Syntax | Purpose |
|---------|--------|---------|
| set-status | `cmux set-status <key> <value> [--icon I] [--color C] [--workspace W]` | Set sidebar status pill |
| clear-status | `cmux clear-status <key> [--workspace W]` | Remove status entry |
| list-status | `cmux list-status [--workspace W]` | List all status entries |
| set-progress | `cmux set-progress <0.0-1.0> [--label T] [--workspace W]` | Set progress bar (0.0 to 1.0) |
| clear-progress | `cmux clear-progress [--workspace W]` | Clear progress bar |
| log | `cmux log [--level L] [--source S] [--workspace W] -- <message>` | Append log entry (levels: info, progress, success, warning, error) |
| list-log | `cmux list-log [--limit N] [--workspace W]` | List log entries |
| clear-log | `cmux clear-log [--workspace W]` | Clear log entries |
| sidebar-state | `cmux sidebar-state [--workspace W]` | Dump all sidebar metadata (cwd, git, ports, status, progress, logs) |

## 8. Sync & Buffers

| Command | Syntax | Purpose |
|---------|--------|---------|
| wait-for | `cmux wait-for [-S \| --signal] <name> [--timeout S]` | Wait for named sync token (no -S) or signal it (-S). Default timeout: 30s |
| set-buffer | `cmux set-buffer [--name N] <text>` | Save text to named buffer |
| list-buffers | `cmux list-buffers` | List all buffers |
| paste-buffer | `cmux paste-buffer [--name N] [--surface S]` | Paste buffer contents into surface |

## 9. Notifications

| Command | Syntax | Purpose |
|---------|--------|---------|
| notify | `cmux notify --title T [--subtitle S] [--body B] [--surface S] [--workspace W]` | Send in-app notification |
| list-notifications | `cmux list-notifications` | List queued notifications |
| clear-notifications | `cmux clear-notifications` | Clear all notifications |

## 10. Claude Integration

| Command | Syntax | Purpose |
|---------|--------|---------|
| claude-hook | `cmux claude-hook <event> [--surface S]` | Hook for Claude Code lifecycle events |
| claude-teams | `cmux claude-teams [claude-args...]` | Start Claude Teams mode |
| omo | `cmux omo [opencode-args...]` | OpenCode integration |
| codex | `cmux codex <install-hooks \| uninstall-hooks>` | Manage Codex CLI hooks |
| markdown | `cmux markdown [open] <path> [--surface S]` | Open markdown in formatted viewer with live reload |
| remote-daemon-status | `cmux remote-daemon-status [--os O] [--arch A]` | Check remote daemon status |

**claude-hook events:** `session-start` (alias: `active`), `stop` (alias: `idle`), `notification` (alias: `notify`), `prompt-submit`

## 11. Search & Hooks

| Command | Syntax | Purpose |
|---------|--------|---------|
| find-window | `cmux find-window [--content] [--select] <query>` | Find workspaces by title or content |
| set-hook | `cmux set-hook [--list] [--unset E] \| <event> <command>` | Manage hook definitions |

## 12. SSH & Remote

| Command | Syntax | Purpose |
|---------|--------|---------|
| ssh | `cmux ssh <dest> [--name N] [--port P] [--identity I] [--no-focus]` | Create SSH workspace with remote proxy |
| (path) | `cmux <path>` | Open directory in new workspace (starts app if needed) |

## 13. Global Options

| Option | Syntax | Purpose |
|--------|--------|---------|
| --id-format | `--id-format refs\|uuids\|both` | Control output ID format (default: refs) |
| --password | `--password <pw>` | Socket auth (flag > `CMUX_SOCKET_PASSWORD` env > saved setting) |
| --json | `--json` | JSON output (supported on select commands) |
| --socket | `--socket PATH` | Custom socket path (overrides `CMUX_SOCKET_PATH`) |
| --window | `--window ID` | Target specific window |
| --workspace | `--workspace ID` | Target specific workspace |
| --surface | `--surface ID` | Target specific surface |
