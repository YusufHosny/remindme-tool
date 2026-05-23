#!/usr/bin/env bash
set -euo pipefail

rm -f  ~/.local/bin/remindme ~/.local/bin/check-reminders
rm -rf ~/.claude/skills/remind
( crontab -l 2>/dev/null | grep -v 'check-reminders' ) | crontab - || true

echo "✓ uninstalled"
echo "  ~/.reminders/ left intact — delete manually if you want to remove your reminder files"
