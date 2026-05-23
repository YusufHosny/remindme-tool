#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Binaries
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/bin/remindme"        ~/.local/bin/remindme
cp "$SCRIPT_DIR/bin/check-reminders" ~/.local/bin/check-reminders
chmod +x ~/.local/bin/remindme ~/.local/bin/check-reminders

# Reminder storage
mkdir -p ~/.reminders

# Claude Code skill
mkdir -p ~/.claude/skills/remind
cp "$SCRIPT_DIR/skill/SKILL.md" ~/.claude/skills/remind/SKILL.md

# Cron job (idempotent — removes any old entry first)
CRON_LINE="1 * * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus $HOME/.local/bin/check-reminders >> $HOME/.reminders/check.log 2>&1"
( crontab -l 2>/dev/null | grep -v 'check-reminders'; echo "$CRON_LINE" ) | crontab -

# PATH check
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "⚠  ~/.local/bin is not in your PATH — add it to your shell profile so 'remindme' is reachable."
fi

echo "✓ installed — try: remindme -t 'Test' -d 'hello' -a 'in 5 minutes'"
