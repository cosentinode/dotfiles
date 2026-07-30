#!/bin/sh

marker="/tmp/yabai-space-changed-$(id -u)"
temporary_marker="${marker}.$$"

trap 'rm -f "$temporary_marker"' EXIT HUP INT TERM
/bin/date +%s.%N > "$temporary_marker" || exit 0
/bin/mv -f "$temporary_marker" "$marker"
