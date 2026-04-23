#!/usr/bin/env bash
set -euo pipefail

# Guard: only run inside cmux
[ -n "${CMUX_SOCKET_PATH:-}" ] || exit 0
command -v cmux >/dev/null 2>&1 || exit 0

# Forward notification to cmux
cmux claude-hook notification 2>/dev/null || true
