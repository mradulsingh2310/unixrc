#!/bin/zsh
# ┌──────────────────────────────────────────────────────────────┐
# │  COPY GITHUB PR LINK FOR THE FOCUSED PANE                    │
# │  Bound to prefix+y (Cmd+Shift+Y via Ghostty)                 │
# │  Synced to: ~/unixrc/herdr/copy-pr-link.sh                   │
# └──────────────────────────────────────────────────────────────┘
#
# Copies the PR URL for whatever repo the FOCUSED split is sitting in.
#
# Why it asks herdr which pane is focused rather than trusting $PWD:
# herdr runs `[[keys.command]]` entries detached, so the working directory and
# $HERDR_PANE_ID of this process are not reliably those of the pane you were
# looking at when you hit the key. `herdr pane current` is also wrong here - it
# means "the pane the CLI was invoked from", which returned focused:false in
# testing. Filtering `pane list` for focused==true is unambiguous.

emulate -L zsh
setopt local_options

notify() {
  # $1 title, $2 body, $3 sound
  if command -v herdr >/dev/null 2>&1; then
    herdr notification show "$1" --body "$2" --position top-right --sound "${3:-none}" >/dev/null 2>&1
  fi
}

# ── locate the focused pane's directory ─────────────────────────
local cwd=""
if command -v herdr >/dev/null 2>&1; then
  cwd=$(herdr pane list 2>/dev/null | python3 -c "
import json,sys
try:
    panes = json.load(sys.stdin)['result']['panes']
except Exception:
    sys.exit(0)
for p in panes:
    if p.get('focused'):
        print(p.get('foreground_cwd') or p.get('cwd') or '')
        break
" 2>/dev/null)
fi

# Fall back to our own cwd if herdr could not tell us.
[[ -n "$cwd" && -d "$cwd" ]] || cwd="$PWD"

builtin cd "$cwd" 2>/dev/null || {
  notify "Copy PR link failed" "Cannot enter $cwd" request
  exit 1
}

# ── must be a git repo ──────────────────────────────────────────
if ! command git rev-parse --git-dir >/dev/null 2>&1; then
  notify "No git repo" "${cwd/#$HOME/~}" request
  exit 1
fi

local branch
branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
  || branch=$(command git rev-parse --short HEAD 2>/dev/null)

if ! command -v gh >/dev/null 2>&1; then
  notify "gh not installed" "brew install gh" request
  exit 1
fi

# ── fetch the PR url ────────────────────────────────────────────
local url
url=$(command gh pr view --json url --jq '.url' 2>/dev/null)

if [[ -z "$url" ]]; then
  notify "No PR for this branch" "$branch" request
  exit 1
fi

printf '%s' "$url" | command pbcopy
notify "PR link copied" "$url" done
exit 0
