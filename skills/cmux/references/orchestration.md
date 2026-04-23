# Multi-Agent Orchestration Reference

Advanced patterns for running and coordinating multiple Claude Code agents using cmux panes.

## 1. Lifecycle

Every multi-agent orchestration follows the same six-phase lifecycle:

1. **Decompose** — Break the task into independent units of work, one per agent
2. **Isolate** — Create a pane for each agent with balanced layout splits
3. **Launch** — Start each agent in interactive mode with clear instructions
4. **Monitor** — Poll agent output to track progress and detect completion
5. **Collect** — Read persisted results from `scratchpad/` files
6. **Clean Up** — Close each pane as its agent finishes, clear sidebar metadata

## 2. Panes vs Workspaces

**Panes (default):** Parallel agents working in the same project, same workspace. Use `cmux new-split` to create splits within the current workspace. This is simpler, faster, and easier to monitor.

**Workspaces:** Only for agents that need completely separate project directories with different `--cwd` (e.g., monorepo subprojects):

```bash
cmux new-workspace --cwd /project/frontend --command "claude 'rebuild React components'"
cmux new-workspace --cwd /project/backend --command "claude 'optimize API endpoints'"
```

Cross-workspace `send` is not supported. If agents need to share the same working directory, use panes.

## 3. Balanced Pane Layout Recipes

Each `new-split` returns the created surface ref. **Always capture it** to target subsequent splits and commands:

```bash
S1=$(cmux new-split right | awk '{print $2}')   # Capture "surface:N" from output
```

**Critical rule: always use `--surface` to target which pane to split.** Without it, cmux splits whichever pane has focus — leading to recursive halving of one pane while others stay untouched.

### 1 agent — single split

```bash
S1=$(cmux new-split right | awk '{print $2}')
# Layout: [orchestrator 50% | agent-1 50%]
```

### 2 agents — split right, then subdivide

```bash
S1=$(cmux new-split right | awk '{print $2}')
S2=$(cmux new-split down --surface $S1 | awk '{print $2}')
# Layout: [orchestrator 50% | agent-1 25%]
#                            | agent-2 25%]
```

### 3 agents — 2x2 grid (all panes equal)

```bash
ORIG=$(cmux identify --json | awk -F'"' '/"surface_ref"/{print $4}')
S1=$(cmux new-split right | awk '{print $2}')
S2=$(cmux new-split down --surface $S1 | awk '{print $2}')
S3=$(cmux new-split down --surface $ORIG | awk '{print $2}')
# Layout: [orchestrator 25% | agent-1 25%]
#         [agent-3 25%      | agent-2 25%]
```

### 4+ agents — extend the 2x2 grid

```bash
# After creating the 2x2 grid above (S1, S2, S3):
S4=$(cmux new-split right --surface $S2 | awk '{print $2}')
# Layout: [orchestrator 25%   | agent-1 25%         ]
#         [agent-3 25%        | agent-2 12% | agent-4 12%]
```

For 5+ agents, continue splitting the largest remaining pane. Alternate between `right` and `down` to keep proportions reasonable.

After splitting, verify topology:

```bash
cmux list-panes           # List all panes with surface refs
cmux tree --json          # Full topology with all refs
```

## 4. Agent Launch

### Interactive mode (RECOMMENDED)

**Always launch agents in interactive mode** (`claude 'prompt'`, NOT `claude -p`). Interactive mode shows real-time streaming output — you can watch agents think, call tools, and produce results. Print mode (`-p`) buffers all output and shows nothing until the agent finishes, making agents appear stuck.

Agents launched interactively don't auto-exit — they stay at the prompt after completing the task. The orchestrator detects completion via `read-screen` and closes the pane with `close-surface`.

### Simple one-liner prompts

Pass the prompt inline with single quotes:

```bash
cmux send --surface $S1 "claude 'implement auth module. Save summary to scratchpad/agent-1.md'\n"
```

### Complex or multi-line prompts

**Write the prompt to a file first, then pass it via `$(cat)`.** This avoids quoting/escaping corruption — `cmux send` interprets `\n` as Enter, which splits multi-line prompts across shell lines, causing `quote>` continuation and stuck input.

```bash
# 1. Write each agent's prompt to a file (use the Write tool):
#    scratchpad/agent-1-prompt.md, scratchpad/agent-2-prompt.md

# 2. Send the command to each agent's pane:
cmux send --surface $S1 "claude \"$(cat scratchpad/agent-1-prompt.md)\"\n"
cmux send --surface $S2 "claude \"$(cat scratchpad/agent-2-prompt.md)\"\n"
```

**Never save prompts to `/tmp/`** or write shell scripts. Use `scratchpad/` for prompt files — they persist and are reviewable.

## 5. Output Persistence

**ALWAYS instruct agents to save results to `scratchpad/`.** Output survives pane closure and the main agent can review results later.

Include in every agent prompt: "When done, save a summary of changes to `scratchpad/agent-<name>.md`"

Each agent should write a summary of its work to a unique file. Results persist after pane closure, so you can close panes immediately after confirming completion.

```bash
# Primary: read persisted output
cat scratchpad/agent-1-auth.md
cat scratchpad/agent-2-tests.md

# Fallback: read screen if scratchpad file missing (only works while pane is open)
cmux read-screen --surface $S1 --scrollback
```

## 6. Monitoring

### Reading agent output

```bash
# Read last 30 lines from a surface
cmux read-screen --surface $S1 --lines 30

# Full scrollback history
cmux read-screen --surface $S1 --scrollback

# Pipe output through a filter
cmux pipe-pane --surface $S1 --command "grep -E '(error|complete|done)'"

# Check health of all surfaces
cmux surface-health
```

### Completion indicators

An agent has finished when:
- The shell prompt appears (`$` or `>` at the end of output)
- Output contains completion messages
- `surface-health` shows idle status

## 7. Sidebar Visibility

Provide orchestration visibility in the sidebar:

```bash
# Status pills — one per agent
cmux set-status "agent-1" "running" --color "#3498db"
cmux set-status "agent-2" "testing" --color "#2ecc71"

# Progress bar (0.0 to 1.0)
cmux set-progress 0.33 --label "1 of 3 done"

# Log entries with severity levels
cmux log "Agent 1 done" --level success
cmux log "Agent 2 hit test failure" --level warning
cmux log "Build failed" --level error
```

Available log levels: `info`, `progress`, `success`, `warning`, `error`

## 8. Inter-Agent Sync

Named synchronization tokens for coordinating between agents with dependencies:

```bash
# Agent 1 signals when auth module is ready
cmux wait-for --signal auth-complete

# Another agent or main pane waits for that signal (blocks until signaled or timeout)
cmux wait-for auth-complete --timeout 300
```

## 9. Named Buffers

Share data between panes using named buffers:

```bash
# Store a result from one agent
cmux set-buffer --name "result" "JWT module implemented at src/auth.ts"

# Retrieve and paste into another agent's surface
cmux paste-buffer --name "result" --surface $S2
```

## 10. Per-Agent Cleanup

Close each surface as its agent finishes. Don't batch cleanup at the end. Since agents save output to `scratchpad/`, results persist after pane closure.

```bash
# When agent-1 finishes:
cmux set-status "agent-1" "done" --color "#27ae60"
cmux set-progress 0.33 --label "1 of 3 agents complete"
cmux close-surface --surface $S1

# When agent-2 finishes:
cmux set-status "agent-2" "done" --color "#27ae60"
cmux set-progress 0.66 --label "2 of 3 agents complete"
cmux close-surface --surface $S2

# When agent-3 finishes:
cmux set-status "agent-3" "done" --color "#27ae60"
cmux set-progress 1.0 --label "3 of 3 agents complete"
cmux close-surface --surface $S3

# After ALL agents finish — clean up sidebar metadata
cmux clear-progress
cmux clear-status "agent-1"
cmux clear-status "agent-2"
cmux clear-status "agent-3"
cmux log "All agents completed — results in scratchpad/" --level success
```

## 11. Error Recovery

### Detecting failures

```bash
cmux pipe-pane --surface $S1 --command "grep -ci 'error\|failed\|exception'"
cmux surface-health
cmux read-screen --surface $S1 --lines 10
```

### Restarting a failed agent

```bash
# Interrupt the current process
cmux send-key --surface $S1 ctrl+c

# Respawn the shell entirely (kills process and starts fresh)
cmux respawn-pane --surface $S1

# Re-launch with retry prompt
cmux send --surface $S1 "claude 'retry: implement auth module. Save summary to scratchpad/agent-1.md'\n"

# Update sidebar status
cmux set-status "agent-1" "retrying" --color "#e74c3c"
```

### Emergency stop all

```bash
cmux send-key --surface $S1 ctrl+c
cmux send-key --surface $S2 ctrl+c
cmux send-key --surface $S3 ctrl+c
```

## 12. Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using CSS selectors instead of element refs | Always `snapshot --interactive`, use `e1`, `e2` refs |
| Forgetting `--interactive` on snapshots | Add `--interactive` flag to every snapshot call |
| Using `-p` mode instead of interactive | Use `claude 'prompt'` not `claude -p 'prompt'` |
| Not waiting after navigation | Add `wait --load-state complete --timeout-ms 15000` |
| Saving prompts to `/tmp/` | Use `scratchpad/agent-N-prompt.md` (persists, reviewable) |
| Batching pane cleanup | Close each surface as its agent finishes |
| Missing `--surface` on `new-split` | Always target: `cmux new-split right --surface $ORIG` |
| Using UUIDs instead of short refs | Use `surface:N` format (default output) |
| Not re-snapshotting after DOM changes | Re-snapshot after navigation, modal open/close, mutations |
| Cross-workspace `send` | Not supported — use `new-split` within same workspace |
| Missing `--dangerously-skip-permissions` | Required for `claude -p` to use tools |
| Not capturing surface ref from `new-split` | `S1=$(cmux new-split right \| awk '{print $2}')` |
| Not waiting for `load-state` after nav | Always `wait --load-state complete` before snapshot |
| Not using `scratchpad/` for output | Include in every agent prompt: "save results to scratchpad/" |
| Using raw `input_*` commands | Use high-level `click`, `fill`, `type` instead |
| Not checking `surface-health` | Use to detect stuck agents |
| Sending multi-line prompts directly | Write to file, send via `$(cat)` substitution |
| Not logging agent milestones | Use `cmux log --level success "message"` |

## 13. Practical Limits

- **5-7 concurrent agents** is the practical ceiling before API rate limits, merge conflicts, and review bottlenecks dominate
- **Breakeven:** ~30+ min sequential work. Tasks under 15 min are slower with multi-agent than doing them sequentially
- **3 Claude Code instances on Pro plan** exhaust rate limits approximately 3x faster
- Each split consumes terminal resources — monitor with `surface-health`
- Agents sharing the same working directory may conflict on file writes — consider workspace-per-project isolation for write-heavy tasks
