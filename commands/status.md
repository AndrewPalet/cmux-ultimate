---
name: status
description: Show current cmux workspace status — surfaces, panes, sidebar state
---

Run these commands and present a clean summary:

1. `cmux identify --json` — current context (workspace, surface, pane, window refs)
2. `cmux list-workspaces` — all open workspaces
3. `cmux list-panes` — pane layout in current workspace
4. `cmux list-pane-surfaces --pane <each pane>` — surfaces per pane
5. `cmux list-log` — recent sidebar log entries

Present the results as a concise overview:
- Current workspace name and ref
- Pane layout (how many panes, their arrangement)
- Surfaces in each pane (terminal vs browser, names)
- Recent log entries if any

If cmux is not available (CMUX_SOCKET_PATH not set), say "Not running inside cmux."
