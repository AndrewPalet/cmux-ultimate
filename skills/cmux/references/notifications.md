# Notifications Reference

## cmux notify (in-app)

**Syntax:**
```
cmux notify --title "Title" --body "Content" [--subtitle "Sub"] [--workspace W]
```

**Behavior:**
- Blue ring around the active pane
- Sidebar badge indicating unread notification
- Entry added to the notification panel

**Jump to unread:** Cmd+Shift+U

**Suppression:** Notification is suppressed when the cmux window is focused, the target workspace is active, or the notification panel is open.

---

## osascript (system-level)

**Syntax:**
```
osascript -e 'display notification "Body" with title "Title" subtitle "Sub" sound name "Hero"'
```

**Behavior:**
- Delivered to macOS Notification Center
- Persists in notification history
- Visible even when the user is in another app

**Sound options:** Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink

---

## Decision Matrix

| Need | Use |
|---|---|
| User is in cmux, agent needs attention | `cmux notify` |
| User in another app, critical alert | `osascript` with sound |
| Build/test complete, informational | `cmux notify` |
| Error requiring immediate attention | `osascript` with sound |
| Context-aware (which pane/workspace) | `cmux notify` |
| Must survive app restart | `osascript` |

---

## Terminal Escape Protocols

- **OSC 9:** `printf '\e]9;message\e\\'` — standard terminal notification
- **OSC 99:** `printf '\e]99;i=id;title\e\\'` — Kitty protocol (supports subtitles)
- **OSC 777:** `printf '\e]777;notify;title;body\e\\'` — RXVT protocol
