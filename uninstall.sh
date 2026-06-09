#!/usr/bin/env bash
set -euo pipefail

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

rm -f  ~/.local/bin/remindme ~/.local/bin/check-reminders
rm -rf ~/.claude/skills/remind

if is_wsl; then
    schtasks.exe /Delete /F /TN "RemindMeCheck" 2>/dev/null || true
    WIN_APPDATA=$(powershell.exe -NoProfile -Command \
        '[Environment]::GetFolderPath("ApplicationData")' 2>/dev/null | tr -d '\r\n')
    [[ -n "$WIN_APPDATA" ]] && rm -rf "$(wslpath "$WIN_APPDATA")/remindme" 2>/dev/null || true
else
    ( crontab -l 2>/dev/null | grep -v 'check-reminders' ) | crontab - || true
fi

echo "✓ uninstalled"
echo "  ~/.reminders/ left intact — delete manually if you want to remove your reminder files"
