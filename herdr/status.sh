#!/bin/zsh
# ┌──────────────────────────────────────────────────────────────┐
# │  HERDR PER-PANE STATUS REPORTER                              │
# │  Synced to: ~/unixrc/herdr/status.sh                         │
# └──────────────────────────────────────────────────────────────┘
#
# Shows, for EACH split independently, its own:
#   path  ·  git branch  ·  PR number + line changes
#
# Rendered in two places, both driven from here:
#   1. the pane's border label  -> sits at the top of that split
#   2. the sidebar agent rows   -> $path / $branch / $pr tokens
#
# Everything is PER-PANE (`herdr pane ...`), not per-workspace. An earlier
# version reported workspace-level metadata and renamed the tab; that was
# wrong on both counts - a tab with 10 splits across 10 repos has only one
# workspace and one tab, so the value was whichever pane wrote last, and the
# tab name froze at whatever it was when the tab opened.
#
# Wired up from ~/.zshrc via precmd/chpwd hooks, so it re-runs on every prompt
# and every cd - which is what makes it track in real time.

emulate -L zsh
setopt local_options no_nomatch

[[ -n "$HERDR_PANE_ID" ]] || return 0
command -v herdr >/dev/null 2>&1 || return 0

local SOURCE="zsh-status"
local PANE="$HERDR_PANE_ID"
local TTL_MS=900000
local PR_CACHE_TTL=120

local CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/herdr-status"
[[ -d "$CACHE_DIR" ]] || mkdir -p "$CACHE_DIR" 2>/dev/null

local pretty="${PWD/#$HOME/~}"

# ── git context (fast, no network) ──────────────────────────────
local git_root branch
git_root=$(command git rev-parse --show-toplevel 2>/dev/null)

if [[ -z "$git_root" ]]; then
  herdr pane report-metadata "$PANE" --source "$SOURCE" \
    --token "path=$pretty" --clear-token branch --clear-token pr \
    --ttl-ms "$TTL_MS" >/dev/null 2>&1
  herdr pane rename "$PANE" "$pretty" >/dev/null 2>&1
  return 0
fi

branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
  || branch=$(command git rev-parse --short HEAD 2>/dev/null)

# Dirty marker - cheap, bounded.
local dirty=""
command git diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty="*"

# ── PR info: disk cache + detached background refresh ───────────
local key="${git_root}::${branch}"
local cache_file="$CACHE_DIR/$(printf '%s' "$key" | command shasum -a 1 | cut -d' ' -f1)"

local pr_text=""
[[ -f "$cache_file" ]] && pr_text=$(<"$cache_file")

local need_refresh=1
if [[ -f "$cache_file" ]]; then
  local age=$(( $(date +%s) - $(command stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
  (( age < PR_CACHE_TTL )) && need_refresh=0
fi

if (( need_refresh )) && command -v gh >/dev/null 2>&1; then
  (
    local out
    out=$(cd "$git_root" && command gh pr view --json number,state,isDraft,additions,deletions,changedFiles \
            --jq '"#\(.number) \(if .isDraft then "DRAFT" else .state end) +\(.additions) -\(.deletions) \(.changedFiles)f"' \
          2>/dev/null)
    if [[ -z "$out" ]]; then
      local ahead
      ahead=$(cd "$git_root" && command git rev-list --count @{upstream}..HEAD 2>/dev/null)
      [[ -n "$ahead" && "$ahead" != "0" ]] && out="no PR ↑${ahead}" || out="no PR"
    fi
    printf '%s' "$out" >| "$cache_file"
  ) >/dev/null 2>&1 &!
fi

# ── report per-pane tokens (sidebar) ────────────────────────────
local -a args
args=( "$PANE" --source "$SOURCE" --ttl-ms "$TTL_MS"
       --token "path=$pretty" --token "branch=${branch}${dirty}" )
if [[ -n "$pr_text" ]]; then
  args+=( --token "pr=$pr_text" )
else
  args+=( --clear-token pr )
fi
herdr pane report-metadata "${args[@]}" >/dev/null 2>&1

# ── pane border label (the "on top" line for this split) ────────
local label="${pretty}  ${branch}${dirty}"
[[ -n "$pr_text" ]] && label="${label}  ${pr_text}"
herdr pane rename "$PANE" "$label" >/dev/null 2>&1

return 0
