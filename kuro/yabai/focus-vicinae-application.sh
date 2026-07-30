#!/bin/sh

target_pid=$1

case $target_pid in
  ''|*[!0-9]*) exit 0 ;;
esac

sleep 0.1

space_change_marker="/tmp/yabai-space-changed-$(id -u)"

space_changed_recently() {
  [ -r "$space_change_marker" ] || return 1

  changed_at=$(command cat "$space_change_marker" 2>/dev/null)
  now=$(/bin/date +%s.%N)

  /usr/bin/awk -v now="$now" -v changed_at="$changed_at" \
    'BEGIN { age = now - changed_at; exit !(age >= 0 && age < 0.6) }'
}

space_changed_recently && exit 0

current_space=$(yabai -m query --spaces --space | jq -r '.index')

if yabai -m query --windows --space "$current_space" | jq -e --argjson pid "$target_pid" '
  any(.[]; .pid == $pid and ."has-ax-reference")
' >/dev/null; then
  exit 0
fi

set -- $(yabai -m query --windows | jq -r --argjson pid "$target_pid" '
  map(select(
    .pid == $pid and
    ."has-ax-reference" and
    .role == "AXWindow" and
    (.subrole == "AXStandardWindow" or .subrole == "AXDialog")
  ))
  | sort_by(."is-minimized")
  | first
  | select(. != null)
  | "\(.id) \(.space)"
')

[ "$#" -eq 2 ] || exit 0

window_id=$1
space_index=$2

space_changed_recently && exit 0

if [ "$space_index" != "$current_space" ]; then
  yabai -m space --focus "$space_index"
fi

yabai -m window --focus "$window_id"
