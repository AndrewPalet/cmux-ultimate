#!/usr/bin/env bash
set -euo pipefail

# Guard: only run inside cmux
[ -n "${CMUX_SOCKET_PATH:-}" ] || exit 0
command -v cmux >/dev/null 2>&1 || exit 0

# Mark session as active (cmux handles workspace naming, branch, and status natively)
cmux claude-hook session-start 2>/dev/null || true
