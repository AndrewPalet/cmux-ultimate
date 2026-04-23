#!/usr/bin/env bash
set -euo pipefail

# Guard: only run inside cmux
[ -n "${CMUX_SOCKET_PATH:-}" ] || exit 0
command -v cmux >/dev/null 2>&1 || exit 0

# Derive project name from git root, fallback to current dir
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")")
# Sanitize: strip newlines, replace / with -
PROJECT=$(echo "$PROJECT" | tr -d '\n' | tr '/' '-')

# Rename workspace tab to project name
cmux rename-workspace "$PROJECT" 2>/dev/null || true

# Log branch to sidebar
BRANCH=$(git branch --show-current 2>/dev/null || echo "no branch")
cmux log --level info -- "$PROJECT . $BRANCH" 2>/dev/null || true

# Mark session as active
cmux claude-hook session-start 2>/dev/null || true
