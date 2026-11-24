#!/bin/bash
# Syncs the skill folder from the main scripts and builds dist/claude-code-mac-notifications-skill.zip.
# The files at the repo root are the source. Run this after you change them.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
skill="$root/skills/claude-code-mac-notifications"
mkdir -p "$skill/hooks" "$root/dist"
cp "$root/install.sh" "$root/uninstall.sh" "$root/LICENSE" "$skill/"
cp "$root/hooks/notify-stop.sh" "$skill/hooks/"
chmod +x "$skill"/*.sh "$skill"/hooks/*.sh
rm -f "$root/dist/claude-code-mac-notifications-skill.zip"
(cd "$root/skills" && zip -qrX "$root/dist/claude-code-mac-notifications-skill.zip" claude-code-mac-notifications -x '.*')
echo "Built dist/claude-code-mac-notifications-skill.zip"
