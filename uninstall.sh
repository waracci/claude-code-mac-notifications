#!/bin/bash
# Removes the notification hook. Other hooks and settings stay as they are.
set -euo pipefail
command -v jq >/dev/null 2>&1 || { echo "jq is necessary. Install it with: brew install jq"; exit 1; }
settings="$HOME/.claude/settings.json"
if [ -f "$settings" ]; then
  cp "$settings" "$settings.bak-$(date +%Y%m%d%H%M%S)"
  tmp=$(mktemp)
  jq 'if .hooks.Stop then
        .hooks.Stop |= (map(.hooks |= map(select((.command // "") | contains("notify-stop.sh") | not))) | map(select(.hooks | length > 0)))
        | if (.hooks.Stop | length) == 0 then del(.hooks.Stop) else . end
        | if (.hooks | length) == 0 then del(.hooks) else . end
      else . end' "$settings" > "$tmp"
  mv "$tmp" "$settings"
fi
rm -f "$HOME/.claude/hooks/notify-stop.sh"
echo "Removed."
