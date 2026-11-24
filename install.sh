#!/bin/bash
# Installs the notification hook for every Claude Code session of this macOS user.
# Safe to run more than one time: it adds the hook only if it is not there yet.
set -euo pipefail

[ "$(uname)" = "Darwin" ] || { echo "This hook works on macOS only."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is necessary. Install it with: brew install jq"; exit 1; }

here=$(cd "$(dirname "$0")" && pwd)
dir="$HOME/.claude"
settings="$dir/settings.json"
hook="$dir/hooks/notify-stop.sh"
cmd='bash ~/.claude/hooks/notify-stop.sh 2>/dev/null || true'

mkdir -p "$dir/hooks"
cp "$here/hooks/notify-stop.sh" "$hook"
chmod +x "$hook"

[ -f "$settings" ] || echo '{}' > "$settings"
jq empty "$settings" 2>/dev/null || { echo "$settings is not valid JSON. Fix it first. Nothing was changed."; exit 1; }

if jq -e --arg c "$cmd" '[.hooks.Stop[]?.hooks[]?.command] | index($c)' "$settings" >/dev/null; then
  echo "The hook is already installed. The script was updated."
else
  backup="$settings.bak-$(date +%Y%m%d%H%M%S)"
  cp "$settings" "$backup"
  tmp=$(mktemp)
  jq --arg c "$cmd" '.hooks.Stop = ((.hooks.Stop // []) + [{"hooks":[{"type":"command","command":$c,"timeout":10}]}])' "$settings" > "$tmp"
  mv "$tmp" "$settings"
  echo "Installed. Backup of your old settings: $backup"
fi

echo '{"last_assistant_message":"The notification hook is installed."}' | bash "$hook"
echo "You should see a test notification now. If not, see 'No notification shows' in the README."
