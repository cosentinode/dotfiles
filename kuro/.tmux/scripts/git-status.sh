#!/usr/bin/env bash

set -u

directory=${1:-}
if [ -z "$directory" ]; then
  printf 'N/A'
  exit 0
fi

now=$(date +%s)
cache_root="${TMPDIR:-/tmp}/tmux-git-status-$UID"
cache_key=$(printf '%s' "$directory" | cksum)
cache_file="$cache_root/${cache_key// /-}"
cache_hit=0

# Avoid running Git on every one-second status redraw.
if mkdir -p "$cache_root" 2>/dev/null && [ -r "$cache_file" ]; then
  cached_at=
  cached_branch=
  cached_summary=
  {
    IFS= read -r cached_at
    IFS= read -r cached_branch
    IFS= read -r cached_summary
  } < "$cache_file"

  case $cached_at in
    ''|*[!0-9]*) ;;
    *)
      if [ "$((now - cached_at))" -lt 5 ]; then
        branch=$cached_branch
        summary=$cached_summary
        cache_hit=1
      fi
      ;;
  esac
fi

if [ "$cache_hit" -eq 0 ]; then
  branch=$(git -C "$directory" symbolic-ref --quiet --short HEAD 2>/dev/null) ||
    branch=$(git -C "$directory" rev-parse --short HEAD 2>/dev/null) || branch=N/A

  summary=
  if [ "$branch" != N/A ]; then
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
  fi

  cache_tmp="$cache_file.$$"
  if printf '%s\n%s\n%s\n' "$now" "$branch" "$summary" > "$cache_tmp" 2>/dev/null; then
    mv -f "$cache_tmp" "$cache_file"
  fi
fi

branch=$("${BASH_SOURCE[0]%/*}/scroll-text.sh" "$branch" 15)

printf '%s%s' "$branch" "$summary"
