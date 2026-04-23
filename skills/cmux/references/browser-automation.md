# Browser Automation Reference

Complete reference for cmux browser automation. All commands follow the pattern:

```
cmux browser [surface:N] <action> [args]
```

## Core Workflow

```
Open -> Snapshot (--interactive) -> Act with refs -> Wait -> Re-snapshot
```

**Rules:**
- ALWAYS use `snapshot --interactive` to get element refs
- NEVER use CSS selectors for interaction — use element refs (e1, e2, e3...)
- ALWAYS re-snapshot after navigation, modal open/close, or major DOM mutations
- Use `--snapshot-after` on mutating actions to auto-refresh refs
- Verify navigation with `get url` before waiting or snapshotting

```bash
cmux --json browser open https://example.com
# returns surface ref, e.g. surface:7

cmux browser surface:7 get url
cmux browser surface:7 wait --load-state complete --timeout-ms 15000
cmux browser surface:7 snapshot --interactive
cmux browser surface:7 fill e1 "hello"
cmux --json browser surface:7 click e2 --snapshot-after
cmux browser surface:7 snapshot --interactive
```

### Stable Agent Loop (Recommended)

```bash
# navigate -> verify -> wait -> snapshot -> action -> snapshot
cmux browser surface:7 get url
cmux browser surface:7 wait --load-state complete --timeout-ms 15000
cmux browser surface:7 snapshot --interactive
cmux --json browser surface:7 click e5 --snapshot-after
cmux browser surface:7 snapshot --interactive
```

If `get url` returns empty or `about:blank`, navigate first instead of waiting on load state.

---

## Navigation

| Command | Description |
|---------|-------------|
| `cmux browser open <url>` | Open URL in caller's workspace (uses CMUX_WORKSPACE_ID) |
| `cmux browser open <url> --json` | Open and return surface ref as JSON |
| `cmux browser open <url> --workspace <id\|ref>` | Open in a specific workspace |
| `cmux browser open-split <url>` | Open in a split view |
| `cmux browser <surface> goto <url>` | Navigate existing surface to URL |
| `cmux browser <surface> back` | Go back in history |
| `cmux browser <surface> forward` | Go forward in history |
| `cmux browser <surface> reload` | Reload page |
| `cmux browser <surface> get url` | Get current URL |
| `cmux browser <surface> get title` | Get page title |

**Workspace context:** `browser open` targets the workspace of the terminal where the command is run (via `CMUX_WORKSPACE_ID`), even if a different workspace is currently focused. Use `--workspace` to override.

---

## Snapshot & Inspection

| Command | Description |
|---------|-------------|
| `snapshot --interactive` | Get DOM tree with element refs (e1, e2...) |
| `snapshot --interactive --compact` | Compact output |
| `snapshot --interactive --max-depth <N>` | Limit DOM traversal depth |
| `snapshot --interactive --selector "<css>"` | Scope snapshot to element |
| `snapshot --interactive --cursor` | Include cursor position |
| `screenshot` | Capture screenshot (base64) |
| `screenshot --out <path>` | Save screenshot to file |
| `screenshot --json` | Screenshot as JSON |
| `highlight <selector-or-ref>` | Visually highlight element |
| `get text <ref-or-selector>` | Get element text content |
| `get html <ref-or-selector>` | Get element inner HTML |
| `get value <ref-or-selector>` | Get input/textarea value |
| `get attr <ref-or-selector> --attr <name>` | Get element attribute |
| `get count "<css-selector>"` | Count matching elements |
| `get box <ref-or-selector>` | Get bounding box |
| `get styles <ref-or-selector> --property <name>` | Get computed styles |
| `eval '<javascript>'` | Evaluate JavaScript expression |

All snapshot/inspection commands are prefixed with `cmux browser <surface>`.

---

## Element Refs

Refs are identifiers like `e1`, `e2`, `e3` assigned by `snapshot --interactive`. They map directly to DOM elements.

**Lifecycle:** Refs are tied to page structure at snapshot time. They become stale when:
- Page navigates to a new URL
- Modal opens or closes
- Major DOM mutations occur (AJAX content load, SPA route change)

**Best practices:**
1. Snapshot before interacting
2. Re-snapshot after navigation/modal/open-close flows
3. Use `--snapshot-after` on mutating actions for automatic refresh
4. Scope snapshots with `--selector` for very large pages

**Troubleshooting stale refs:**

```bash
# not_found / stale ref -> re-snapshot
cmux browser surface:7 snapshot --interactive

# Element not visible -> wait + scroll + re-snapshot
cmux browser surface:7 wait --selector "#target" --timeout-ms 10000
cmux browser surface:7 scroll --dy 400
cmux browser surface:7 snapshot --interactive

# Too many elements -> scope the snapshot
cmux browser surface:7 snapshot --selector "form#checkout" --interactive
```

---

## Interaction

| Command | Description |
|---------|-------------|
| `click <ref>` | Click element |
| `click <ref> --snapshot-after --json` | Click and return fresh snapshot |
| `dblclick <ref>` | Double-click element |
| `hover <ref>` | Hover over element |
| `focus <ref>` | Focus element |
| `fill <ref> "<text>"` | Fill input (replaces content) |
| `fill <ref> ""` | Clear input (empty string = clear) |
| `type <ref> "<text>"` | Type text (appends to existing) |
| `press <key>` | Press key (e.g. Enter, Tab, Escape) |
| `keydown <key>` | Key down event |
| `keyup <key>` | Key up event |
| `select <ref> "<value>"` | Select dropdown option by value |
| `check <ref>` | Check checkbox |
| `uncheck <ref>` | Uncheck checkbox |
| `scroll --dy <pixels>` | Scroll page vertically |
| `scroll --dx <pixels>` | Scroll page horizontally |
| `scroll --selector "<css>" --dy <pixels>` | Scroll within a specific element |
| `scroll-into-view <ref>` | Scroll element into viewport |

All interaction commands are prefixed with `cmux browser <surface>`.

---

## Find (Playwright Locators)

| Command | Description |
|---------|-------------|
| `find role <role>` | Find by ARIA role (button, link, textbox...) |
| `find role <role> --name "<text>" --exact` | Find by role with exact name match |
| `find text "<text>"` | Find by visible text |
| `find label "<text>"` | Find by form label |
| `find placeholder "<text>"` | Find by placeholder attribute |
| `find alt "<text>"` | Find by alt text |
| `find title "<text>"` | Find by title attribute |
| `find testid "<id>"` | Find by data-testid |
| `find first` | First matching element |
| `find last` | Last matching element |
| `find nth <N>` | Nth matching element (0-indexed) |

All find commands are prefixed with `cmux browser <surface>`.

---

## Element State

| Command | Description |
|---------|-------------|
| `is visible <ref>` | Check if element is visible |
| `is enabled <ref>` | Check if element is enabled |
| `is checked <ref>` | Check if checkbox/radio is checked |

All state commands are prefixed with `cmux browser <surface>`.

---

## Wait

| Flag | Description |
|------|-------------|
| `--selector "<css>"` | Wait for element to appear in DOM |
| `--text "<text>"` | Wait for text to appear on page |
| `--url-contains "<substring>"` | Wait for URL to contain string |
| `--load-state <state>` | Wait for load state: `interactive` or `complete` |
| `--function "<js>"` | Wait for JS expression to return truthy |
| `--timeout-ms <ms>` | Timeout in milliseconds (default varies) |

```bash
cmux browser <surface> wait --selector "#ready" --timeout-ms 10000
cmux browser <surface> wait --text "Done" --timeout-ms 10000
cmux browser <surface> wait --url-contains "/dashboard" --timeout-ms 10000
cmux browser <surface> wait --load-state complete --timeout-ms 15000
cmux browser <surface> wait --function "document.readyState === 'complete'" --timeout-ms 10000
```

---

## Session & State

### Cookies

```bash
cmux browser <surface> cookies get
cmux browser <surface> cookies set --name "session" --value "abc123"
cmux browser <surface> cookies set session_token "abc123xyz"
cmux browser <surface> cookies clear
```

### Storage

```bash
cmux browser <surface> storage local get --key "user"
cmux browser <surface> storage local set --key "prefs" --value '{"theme":"dark"}'
cmux browser <surface> storage local clear
cmux browser <surface> storage session get --key "token"
cmux browser <surface> storage session set --key "token" --value "xyz"
cmux browser <surface> storage session clear
```

### State Persistence

```bash
cmux browser <surface> state save ./auth-state.json
cmux browser <surface> state load ./auth-state.json
```

State includes cookies, localStorage, sessionStorage, and open tab metadata.

### Tabs

```bash
cmux browser <surface> tab list
cmux browser <surface> tab new
cmux browser <surface> tab switch <index>
cmux browser <surface> tab close <index>
```

---

## Dialogs & Frames

### Dialogs

```bash
cmux browser <surface> dialog accept              # Accept alert/confirm
cmux browser <surface> dialog accept "input text"  # Accept prompt with text
cmux browser <surface> dialog dismiss              # Dismiss dialog
```

### Frames (iframes)

```bash
cmux browser <surface> frame "#iframe-id"    # Switch to iframe context
cmux browser <surface> frame main            # Switch back to main frame
```

---

## Script Injection

```bash
# Inject JS that runs on every page load
cmux browser <surface> addinitscript 'console.log("injected on every load")'

# Inject one-time JS
cmux browser <surface> addscript 'document.title = "modified"'

# Inject CSS
cmux browser <surface> addstyle 'body { background: #f0f0f0; }'
```

---

## Diagnostics

| Command | Description |
|---------|-------------|
| `console list` | View console messages |
| `console clear` | Clear console log |
| `errors list` | View JavaScript errors |
| `errors clear` | Clear error log |
| `download wait --timeout-ms <ms>` | Wait for a file download to complete |

All diagnostic commands are prefixed with `cmux browser <surface>`.

---

## WKWebView Limitations

These commands return `not_supported` because they rely on Chrome/CDP-only APIs not available in WKWebView:

| Command | Status |
|---------|--------|
| `viewport.set` | not_supported |
| `geolocation.set` | not_supported |
| `offline.set` | not_supported |
| `trace.start\|stop` | not_supported |
| `network.route\|unroute\|requests` | not_supported |
| `screencast.start\|stop` | not_supported |
| `input_mouse\|input_keyboard\|input_touch` | not_supported |

Use high-level commands (`click`, `fill`, `type`, `press`, `scroll`, `wait`, `snapshot`) instead.

---

## Shell Templates

### Form Automation

```bash
#!/usr/bin/env bash
set -euo pipefail

URL="${1:-https://example.com/form}"
SURFACE="${2:-surface:1}"

cmux browser "$SURFACE" goto "$URL"
cmux browser "$SURFACE" get url
cmux browser "$SURFACE" wait --load-state complete --timeout-ms 15000
cmux browser "$SURFACE" snapshot --interactive

echo "Now run fill/click commands using refs from the snapshot above."
```

### Authenticated Session

```bash
#!/usr/bin/env bash
set -euo pipefail

SURFACE="${1:-surface:1}"
STATE_FILE="${2:-./auth-state.json}"
DASHBOARD_URL="${3:-https://app.example.com/dashboard}"

if [ -f "$STATE_FILE" ]; then
  cmux browser "$SURFACE" state load "$STATE_FILE"
fi

cmux browser "$SURFACE" goto "$DASHBOARD_URL"
cmux browser "$SURFACE" get url
cmux browser "$SURFACE" wait --load-state complete --timeout-ms 15000
cmux browser "$SURFACE" snapshot --interactive

echo "If redirected to login, complete login flow then run:"
echo "  cmux browser $SURFACE state save $STATE_FILE"
```

### Capture Workflow

```bash
#!/usr/bin/env bash
set -euo pipefail

SURFACE="${1:-surface:1}"
OUT_DIR="${2:-./browser-artifacts}"
mkdir -p "$OUT_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
cmux browser "$SURFACE" snapshot --interactive > "$OUT_DIR/snapshot-$TS.txt"
cmux browser "$SURFACE" screenshot > "$OUT_DIR/screenshot-$TS.b64"

echo "Wrote: $OUT_DIR/snapshot-$TS.txt"
echo "Wrote: $OUT_DIR/screenshot-$TS.b64"
```

---

## Auth Patterns

### Basic Login Flow

```bash
cmux browser open https://app.example.com/login --json
cmux browser surface:7 wait --load-state complete --timeout-ms 15000
cmux browser surface:7 snapshot --interactive
# [ref=e1] email, [ref=e2] password, [ref=e3] submit

cmux browser surface:7 fill e1 "user@example.com"
cmux browser surface:7 fill e2 "$APP_PASSWORD"
cmux browser surface:7 click e3 --snapshot-after --json
cmux browser surface:7 wait --url-contains "/dashboard" --timeout-ms 20000
```

### OAuth / SSO Flow

```bash
cmux browser open https://app.example.com/auth/google --json
cmux browser surface:7 wait --url-contains "accounts.google.com" --timeout-ms 30000
cmux browser surface:7 snapshot --interactive

cmux browser surface:7 fill e1 "user@gmail.com"
cmux browser surface:7 click e2 --snapshot-after --json

# Wait for redirect back to app
cmux browser surface:7 wait --url-contains "app.example.com" --timeout-ms 45000
cmux browser surface:7 state save ./oauth-state.json
```

### Two-Factor Authentication

```bash
cmux browser open https://app.example.com/login --json
cmux browser surface:7 snapshot --interactive
cmux browser surface:7 fill e1 "user@example.com"
cmux browser surface:7 fill e2 "$APP_PASSWORD"
cmux browser surface:7 click e3

# Complete 2FA manually in the webview, then:
cmux browser surface:7 wait --url-contains "/dashboard" --timeout-ms 120000
cmux browser surface:7 state save ./2fa-state.json
```

### Token Refresh Handling

```bash
#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="./auth-state.json"
SURFACE="surface:7"

if [ -f "$STATE_FILE" ]; then
  cmux browser "$SURFACE" state load "$STATE_FILE"
fi

cmux browser "$SURFACE" goto https://app.example.com/dashboard
URL=$(cmux browser "$SURFACE" get url)

if printf '%s' "$URL" | grep -q '/login'; then
  cmux browser "$SURFACE" snapshot --interactive
  cmux browser "$SURFACE" fill e1 "$APP_USERNAME"
  cmux browser "$SURFACE" fill e2 "$APP_PASSWORD"
  cmux browser "$SURFACE" click e3
  cmux browser "$SURFACE" wait --url-contains "/dashboard" --timeout-ms 20000
  cmux browser "$SURFACE" state save "$STATE_FILE"
fi
```

### Cookie-Based Auth

```bash
cmux browser surface:7 cookies set session_token "abc123xyz"
cmux browser surface:7 goto https://app.example.com/dashboard
```

### Saving & Restoring State

```bash
# Save after login
cmux browser surface:7 state save ./auth-state.json

# Restore in a new session
cmux browser open https://app.example.com --json
cmux browser surface:8 state load ./auth-state.json
cmux browser surface:8 goto https://app.example.com/dashboard
cmux browser surface:8 snapshot --interactive
```

### Security Best Practices

1. Never commit state files — they contain auth tokens
2. Use environment variables for credentials (`$APP_PASSWORD`, not literals)
3. Clear state/cookies after sensitive tasks:

```bash
cmux browser surface:7 cookies clear
rm -f ./auth-state.json
```

---

## Troubleshooting

### `js_error` on `snapshot --interactive` or `eval`

Some complex pages reject the JavaScript used for rich snapshots.

```bash
# Check where you actually are
cmux browser surface:7 get url

# Fall back to raw content extraction
cmux browser surface:7 get text body
cmux browser surface:7 get html body
```

If the page keeps failing, navigate to a simpler intermediate page and retry.
