# cmux-ultimate

**Complete cmux integration for Claude Code — workspace management, browser automation, multi-agent orchestration, sidebar metadata, and lifecycle hooks in one plugin.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-orange.svg)](https://github.com/anthropics/claude-code)
[![cmux](https://img.shields.io/badge/cmux-Terminal-blue.svg)](https://github.com/manaflow-ai/cmux)
[![macOS](https://img.shields.io/badge/macOS-14.0+-999999.svg)](https://www.apple.com/macos/)

## Features

- Single `/cmux` skill with progressive disclosure via 4 reference docs
- Full CLI reference (~130 commands, verified against cmux v0.63.1)
- Browser automation (~40 subcommands with element ref workflow, templates, auth patterns)
- Multi-agent orchestration (pane layouts, agent launch, monitoring, sync, common mistakes)
- Notification decision matrix (cmux notify vs osascript)
- Auto workspace naming (SessionStart hook renames tab to git repo)
- Active/idle sidebar status (session lifecycle hooks)
- Completion notifications (Stop hook)
- `/cmux:status` and `/cmux:open-browser` slash commands
- Always-on rules file for proactive cmux awareness

## Installation

```bash
claude plugin marketplace add AndrewPalet/cmux-ultimate
claude plugin install cmux-ultimate
```

## Requirements

- macOS 14.0+
- cmux terminal installed and running
- Claude Code CLI
- jq (for notification hook)

## What Happens Automatically

- Workspace tab renames to git repo name on session start
- Sidebar shows branch info
- Status updates to active/idle as Claude works
- Completion notification when session ends

## What You Can Invoke

- `/cmux` — full CLI reference and skill guide
- `/cmux:status` — current workspace overview
- `/cmux:open-browser [url]` — open browser split and report contents

## File Structure

```
cmux-ultimate/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── commands/
│   ├── open-browser.md
│   └── status.md
├── docs/
│   └── superpowers/
│       ├── plans/
│       │   └── 2026-04-23-cmux-ultimate-plugin.md
│       └── specs/
│           └── 2026-04-23-cmux-ultimate-plugin-design.md
├── hooks/
│   └── hooks.json
├── rules/
│   └── cmux-guide.md
├── scripts/
│   ├── notification.sh
│   ├── session-start.sh
│   └── session-stop.sh
├── skills/
│   └── cmux/
│       ├── references/
│       │   ├── browser-automation.md
│       │   ├── complete-cli.md
│       │   ├── notifications.md
│       │   └── orchestration.md
│       └── SKILL.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Credits

Built by combining the best from:

- [goddaehee/cmux-claude-skill](https://github.com/goddaehee/cmux-claude-skill) — verified CLI reference, tmux migration
- [ph3on1x/claude-cmux-skill](https://github.com/ph3on1x/claude-cmux-skill) — orchestration patterns, hooks, common mistakes
- [hopchouinard/cmux-plugin](https://github.com/hopchouinard/cmux-plugin) — workspace naming, slash commands, restraint guidelines
- [mangledmonkey/cmux-skills](https://github.com/mangledmonkey/cmux-skills) — browser templates, auth patterns, markdown viewer

## License

MIT
