#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

# Dependencies
if command -v apt-get &>/dev/null; then
    sudo apt-get install -y -q zenity jq
fi

# Binaries
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/bin/remindme"        ~/.local/bin/remindme
cp "$SCRIPT_DIR/bin/check-reminders" ~/.local/bin/check-reminders
chmod +x ~/.local/bin/remindme ~/.local/bin/check-reminders

# Reminder storage
mkdir -p ~/.reminders

# Scheduler
if is_wsl; then
    WSL_USER="$(whoami)"
    WSL_SCRIPT="$HOME/.local/bin/check-reminders"

    # Create a VBScript wrapper so wscript.exe launches wsl.exe with a hidden window
    WIN_APPDATA=$(powershell.exe -NoProfile -Command \
        '[Environment]::GetFolderPath("ApplicationData")' 2>/dev/null | tr -d '\r\n')
    WSL_APPDATA=$(wslpath "$WIN_APPDATA")
    mkdir -p "$WSL_APPDATA/remindme"

    VBS_FILE="$WSL_APPDATA/remindme/check-reminders.vbs"
    cat > "$VBS_FILE" <<EOF
Set oShell = CreateObject("WScript.Shell")
oShell.Run "wsl.exe -u $WSL_USER -- $WSL_SCRIPT", 0, False
EOF

    WIN_VBS=$(wslpath -w "$VBS_FILE")

    schtasks.exe /Delete /F /TN "RemindMeCheck" 2>/dev/null || true
    schtasks.exe /Create /F /SC MINUTE /MO 5 \
        /TN "RemindMeCheck" \
        /TR "wscript.exe \"$WIN_VBS\""
    echo "✓ Windows Task Scheduler job 'RemindMeCheck' created (runs every 5 minutes)"
else
    CRON_LINE="*/5 * * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus $HOME/.local/bin/check-reminders >> $HOME/.reminders/check.log 2>&1"
    ( crontab -l 2>/dev/null | grep -v 'check-reminders'; echo "$CRON_LINE" ) | crontab -
    echo "✓ cron job installed (runs every 5 minutes)"
fi

# PATH check
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "⚠  ~/.local/bin is not in your PATH — add it to your shell profile so 'remindme' is reachable."
fi

echo "✓ installed — try: remindme -t 'Test' -d 'hello' -a 'in 5 minutes'"
echo "   to install the AI skill: bash install-skill.sh"
