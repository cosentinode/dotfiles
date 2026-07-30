#!/usr/bin/env bash

set -u

text=${1:-}
width=${2:-15}

if [ "${#text}" -le "$width" ]; then
  printf '%s' "$text"
  exit 0
fi

cycle="$text | "
offset=$(($(date +%s) % ${#cycle}))
marquee="${cycle}${cycle}"
printf '%s' "${marquee:offset:width}"
