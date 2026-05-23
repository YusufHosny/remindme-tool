# remindme

A minimal local reminder tool system for Linux with a coding agent skill integration.

I dont plan to add native windows support, but I'll prob setup WSL2 support sooner or later.

## How it works

1. You create a reminder — via the `remindme` CLI or through the agent skill.
2. Reminders are stored as JSON files in `~/.reminders/`.
3. A cron job runs every 5min and shows a dialog for any due reminders.

## Requirements

- `python3` (stdlib only)
- `zenity` — for the notification dialog
- `jq` — for parsing reminder files in the cron script
- `cron` — for the hourly check

## Install

```bash
bash install.sh
```

Copies the binaries to `~/.local/bin/`, creates `~/.reminders/`, and adds the cron job. Safe to re-run (idempotent). No AI agent dependency.

**Optionally install the AI skill:**

```bash
bash install-skill.sh           # Claude Code (default)
bash install-skill.sh cc        # same
bash install-skill.sh claude-code  # same
```

Requires `~/.claude/` to exist (i.e. Claude Code must be installed). For other agents, the script will tell you to copy `skill/SKILL.md` manually.
I may add support for opencode or other agents eventually.

## Uninstall

```bash
bash uninstall.sh
```

Removes binaries, skill, and cron entry. Leaves `~/.reminders/` intact.

## Usage

### From a Coding Agent

Just say it naturally:

> "remind me to review the deploy PR monday 9am"
> "remind me about the team retro tomorrow at 2pm"
> "remind me to pay the invoice in 3 days"

The `/remind` skill picks it up, extracts the structured fields, and calls `remindme` for you.

### From the terminal

**Create:**
```
remindme -t <title> -d <description> [-c <content>] -a <when>
```

**List:**
```
remindme --list
```
```
  1  Sat May 24 at 9:00 AM  Review deploy PR — Check the open deploy PR before end of day
  2  Mon May 26 at 2:00 PM  Check Tests — Check if tests passed on CI at 2
```

**Delete by index:**
```
remindme --delete 1
```

| Flag | Required | Description |
|------|----------|-------------|
| `-t` / `--title` | yes | Short label (3–6 words) |
| `-d` / `--description` | yes | One-sentence summary |
| `-c` / `--content` | no | Full details (shown when you click Open) |
| `-a` / `--at` | yes | When to remind |
| `-l` / `--list` | — | List all pending reminders |
| `-D` / `--delete N` | — | Delete reminder #N (from `--list`) |

**Supported `--at` formats:**

| Input | Meaning |
|-------|---------|
| `tomorrow 9am` | Next day at 09:00 |
| `monday 2pm` | Next Monday at 14:00 |
| `today 3:30pm` | Today at 15:30 (tomorrow if already past) |
| `in 2 hours` | 2 hours from now |
| `in 30m` | 30 minutes from now |
| `in 1d` | 24 hours from now |
| `9am` | Today at 09:00 (tomorrow if past) |
| `2026-05-26 09:00` | Absolute datetime |

## Reminder files

Stored in `~/.reminders/<unix_timestamp>-<slug>.json`:

```json
{
  "title": "Review deploy PR",
  "description": "Check the open deploy PR before end of day",
  "content": "PR #42 in the infra repo — needs approval before the Friday freeze"
}
```

## Notification dialog

When a reminder is due the cron script shows a zenity dialog with:

- **Open** — writes the full content to a temp file and opens it in your default terminal + `$EDITOR`. Deletes the reminder.
- **Snooze 5min** — reschedules for 5 minutes later.
- **Dismiss** — deletes the reminder.

Cron output and errors are logged to `~/.reminders/check.log`.
