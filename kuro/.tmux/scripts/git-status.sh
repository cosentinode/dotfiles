#!/usr/bin/env bash

set -u

directory=${1:-}
if [ -z "$directory" ]; then
  printf 'N/A'
  exit 0
fi

branch=$(git -C "$directory" symbolic-ref --quiet --short HEAD 2>/dev/null) ||
  branch=$(git -C "$directory" rev-parse --short HEAD 2>/dev/null) || {
    printf 'N/A'
    exit 0
  }

summary=$(
  git -C "$directory" status --porcelain 2>/dev/null | awk '
    substr($0, 1, 2) == "??" { untracked++; next }
    substr($0, 1, 1) != " " { staged++ }
    substr($0, 2, 1) != " " { modified++ }
    END {
      if (staged) printf " +%d", staged
      if (modified) printf " ~%d", modified
      if (untracked) printf " ?%d", untracked
    }
  '
)

printf '%s%s' "$branch" "$summary"
