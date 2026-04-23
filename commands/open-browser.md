---
name: open-browser
description: Open a browser split pane to a URL and report what's visible
---

Open a browser pane in the current workspace and report what's on the page.

**Arguments:** `[url]` — URL to open (defaults to `http://localhost:3000`)

If the argument contains both a URL and additional text (e.g., "localhost:5173 check the login form"), parse the URL portion and treat the rest as intent to investigate after loading.

**Steps:**

1. Check cmux is available (`CMUX_SOCKET_PATH` set, `cmux` binary exists). If not, say "Not running inside cmux."
2. Get current surface: `cmux identify --json`
3. Open browser split: `cmux browser open-split <url> --json`
4. Wait for page: `cmux browser <surface> wait --load-state complete --timeout-ms 15000`
5. Take snapshot: `cmux browser <surface> snapshot --interactive --compact`
6. Report what's visible on the page
7. If the user included intent text, investigate that specific aspect
