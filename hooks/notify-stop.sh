#!/bin/bash
# Claude Code Stop hook: show a macOS notification when a session finishes its turn.
# Title: "Claude Code". Subtitle: the project folder. Text: the first words of
# Claude's last message, so you can see what the session did.
#
# Settings (optional, environment variables):
#   CLAUDE_NOTIFY_SOUND   notification sound name (default: Glass). Set it empty for no sound.
#   CLAUDE_NOTIFY_WORDS   how many words of the last message to show (default: 12).

in=$(cat)
command -v jq >/dev/null 2>&1 || { osascript -e 'display notification "Finished" with title "Claude Code"'; exit 0; }

cwd=$(jq -r '.cwd // empty' <<<"$in" 2>/dev/null)
name=$(basename "${cwd:-$PWD}")

# Newer Claude Code versions send the last message in the hook input.
msg=$(jq -r '.last_assistant_message // empty' <<<"$in" 2>/dev/null)
# Older versions: read it from the end of the session transcript.
if [ -z "$msg" ]; then
  tp=$(jq -r '.transcript_path // empty' <<<"$in" 2>/dev/null)
  if [ -f "$tp" ]; then
    msg=$(tail -n 200 "$tp" | jq -rs '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text] | last // empty' 2>/dev/null)
  fi
fi

# First line with text, markdown removed, limited to a few words.
words=${CLAUDE_NOTIFY_WORDS:-12}
desc=$(printf '%s\n' "$msg" | sed -E 's/\[([^]]*)\]\([^)]*\)/\1/g; s/[*`#>_|]//g' | awk 'NF{print; exit}' | cut -d' ' -f1-"$words")
[ ${#desc} -gt 110 ] && desc="${desc:0:107}..."
[ -z "$desc" ] && desc="Finished"

sound=${CLAUDE_NOTIFY_SOUND-Glass}

# Pass the text as arguments, not inside the script, so quotes in a message cannot break it.
osascript - "$desc" "$name" "$sound" <<'APPLESCRIPT' >/dev/null 2>&1
on run argv
  set theText to item 1 of argv
  set theFolder to item 2 of argv
  set theSound to item 3 of argv
  if theSound is "" then
    display notification theText with title "Claude Code" subtitle theFolder
  else
    display notification theText with title "Claude Code" subtitle theFolder sound name theSound
  end if
end run
APPLESCRIPT
exit 0
