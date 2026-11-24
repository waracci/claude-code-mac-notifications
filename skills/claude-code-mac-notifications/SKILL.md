---
name: claude-code-mac-notifications
description: Set up macOS notifications that show when a Claude Code session finishes, with the project name and the first words of what Claude did. Use when the user asks for a notification, alert, banner or sound when Claude Code finishes, or wants to change, test, troubleshoot or remove these notifications.
license: MIT
compatibility: Claude Code on macOS. Needs jq. alerter is optional.
metadata:
  version: "1.1.0"
  source: https://github.com/waracci/claude-code-mac-notifications
---

# Claude Code Mac Notifications

This skill installs a Claude Code `Stop` hook. Each time a session finishes its turn, macOS shows a banner:

- **Title:** Claude Code
- **Subtitle:** the project folder name
- **Text:** the first words (about 12) of Claude's last reply, without markdown

Everything runs on the user's Mac. The hook sends no data, writes no files and keeps no logs. It always exits with code 0 and ends in less than 0.1 s, so it can never block a session.

The files next to this SKILL.md:

| File | What it does |
|---|---|
| `hooks/notify-stop.sh` | The hook script |
| `install.sh` | Copies the script to `~/.claude/hooks/`, backs up `~/.claude/settings.json`, adds one `Stop` hook, and shows a test banner. Safe to run again. |
| `uninstall.sh` | Backs up the settings, removes only this hook and the script |

## Install

Follow these steps in order. Tell the user what you do before each step that changes a file.

1. **Check the system.** Run `uname`. If it is not `Darwin`, stop and tell the user that this works on macOS only.
2. **Check jq.** Run `command -v jq`. If it is missing, ask the user to run `brew install jq`, or run it with their OK.
3. **Check for an existing install.** Run `jq '.hooks.Stop' ~/.claude/settings.json` and `claude plugin list 2>/dev/null | grep -i mac-notifications`. If the plugin `mac-notifications` is installed, do not run the installer: the user would get two banners for each finish. Tell the user it is already installed.
4. **Run the installer** from this skill's folder: `bash <skill-folder>/install.sh`. It prints the path of the settings backup.
5. **Confirm.** Ask the user if they saw the test banner "The notification hook is installed."
6. **Tell the user** that new sessions use the hook at once. In a session that is already open, they type `/hooks` one time, or restart it.

## If no banner shows

- macOS shows `osascript` banners as **Script Editor** notifications. Ask the user to open **System Settings → Notifications → Script Editor** and turn on **Allow notifications**. On some macOS versions the entry is the terminal app.
- A Focus mode (Do Not Disturb) hides banners.
- Test the script directly:
  `echo '{"cwd":"/tmp/demo","last_assistant_message":"Hello from the hook."}' | bash ~/.claude/hooks/notify-stop.sh`

## Optional: Ack button, one banner per session

The default banner has a **Show** button that opens Script Editor. For a better banner, the user can install [alerter](https://github.com/vjeantet/alerter) (a signed, open-source notifier). Put the binary at `~/.claude/bin/alerter` or anywhere on `PATH`. The hook finds it by itself. Then:

- The banner has an **Ack** button that only closes it.
- Each session keeps one banner: a new finish replaces the old one.

Then ask the user to open **System Settings → Notifications → alerter** and set:
- **Banner style: Persistent**, so the banners stay until they click Ack.
- **Notification grouping: Off**, so each banner shows on its own.

Download alerter only with the user's OK, from its GitHub releases page.

## Settings

The user sets these in the `env` object of `~/.claude/settings.json`, or in their shell profile:

| Variable | Default | What it does |
|---|---|---|
| `CLAUDE_NOTIFY_SOUND` | `Glass` | Sound name from `/System/Library/Sounds`. Empty = no sound. |
| `CLAUDE_NOTIFY_WORDS` | `12` | Number of words from the reply. |
| `CLAUDE_NOTIFY_ACK` | `Ack` | The button text with alerter. |
| `CLAUDE_NOTIFY_ALERTER` | (none) | Full path to alerter, if it is not found. |

## Privacy

The banner shows the first words of Claude's reply, and the lock screen can show banners too. For private work, suggest **System Settings → Notifications → Show previews → When Unlocked**.

## Remove

Run `bash <skill-folder>/uninstall.sh`. It backs up the settings and removes only this hook and the script. To pause it, the user can use `/hooks`.
