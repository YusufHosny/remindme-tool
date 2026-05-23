# reminders

A minimal local reminder system for Linux with Claude Code integration.

## How it works

1. You create a reminder — via the `remindme` CLI or by telling Claude Code "remind me to X".
2. Reminders are stored as JSON files in `~/.reminders/`.
3. A cron job runs every hour at `:01` and shows a dialog for any due reminders.

## Requirements

- `python3` (stdlib only)
- `zenity` — for the notification dialog
- `jq` — for parsing reminder files in the cron script
- `cron` — for the hourly check

## Install

```bash
bash install.sh
```

This copies the binaries to `~/.local/bin/`, installs the Claude Code skill to `~/.claude/skills/remind/`, creates `~/.reminders/`, and adds the cron job. Running it again is safe (idempotent).

## Uninstall

```bash
bash uninstall.sh
```

Removes binaries, skill, and cron entry. Leaves `~/.reminders/` intact.

## Usage

### From Claude Code

Just say it naturally:

> "remind me to review the deploy PR monday 9am"
> "remind me about the team retro tomorrow at 2pm"
> "remind me to pay the invoice in 3 days"

The `/remind` skill picks it up, extracts the structured fields, and calls `remindme` for you.

### From the terminal

```
remindme -t <title> -d <description> -c <content> -a <when>
```

| Flag | Required | Description |
|------|----------|-------------|
| `-t` / `--title` | yes | Short label (3–6 words) |
| `-d` / `--description` | yes | One-sentence summary |
| `-c` / `--content` | no | Full details (shown when you click Open) |
| `-a` / `--at` | yes | When to remind |

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

Missed reminders catch up: if the 10:01 job didn't run, the 11:01 job will pick up anything due before 11:01.

Cron output and errors are logged to `~/.reminders/check.log`.
