#!/usr/bin/env bash
set -euo pipefail

# Guard: only run inside cmux
[ -n "${CMUX_SOCKET_PATH:-}" ] || exit 0
command -v cmux >/dev/null 2>&1 || exit 0

# Mark session as idle
cmux claude-hook stop 2>/dev/null || true

# Send completion notification
cmux notify --title "Claude Code" --body "Session complete - ready for review" 2>/dev/null || true
