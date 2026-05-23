#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Join all args so no space issues
AGENT="${*:-claude}"

case "${AGENT,,}" in
    claude|claude-code|cc|"claude code")
        if [[ ! -d "$HOME/.claude" ]]; then
            echo "Error: ~/.claude not found — is Claude Code installed?"
            exit 1
        fi
        mkdir -p "$HOME/.claude/skills/remind"
        cp "$SCRIPT_DIR/skill/SKILL.md" "$HOME/.claude/skills/remind/SKILL.md"
        echo "✓ skill installed to ~/.claude/skills/remind/"
        ;;
    *)
        echo "Unsupported agent: '$AGENT'"
        echo "Only Claude Code is supported for now."
        echo "To install manually, copy skill/SKILL.md to wherever '$AGENT' loads skills from."
        ;;
esac
