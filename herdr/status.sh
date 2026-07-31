#!/bin/zsh
# ┌──────────────────────────────────────────────────────────────┐
# │  HERDR STATUS REPORTER                                       │
# │  Feeds path + PR info into herdr's sidebar as custom tokens. │
# │  Synced to: ~/unixrc/herdr/status.sh                         │
# └──────────────────────────────────────────────────────────────┘
#
# herdr already computes `branch` and `git_status` itself (built-in sidebar
# tokens), so this only reports what it CAN'T know:
#   $path  - abbreviated cwd
#   $pr    - pull request state + diff stats, via `gh`
#
# Wired up from ~/.zshrc via precmd/chpwd hooks.
#
# Design note: `gh pr view` is a network call (~300-800ms) and precmd runs on
# every prompt, so PR data is CACHED on disk and refreshed in a detached
# background job. The prompt never blocks on the network.

emulate -L zsh
setopt local_options no_nomatch

# Not inside herdr -> nothing to report.
[[ -n "$HERDR_WORKSPACE_ID" ]] || return 0
command -v herdr >/dev/null 2>&1 || return 0

local SOURCE="zsh-status"
local WS="$HERDR_WORKSPACE_ID"
local TTL_MS=900000          # 15min - tokens outlive an idle prompt
local PR_CACHE_TTL=120       # seconds before PR data is considered stale

local CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/herdr-status"
[[ -d "$CACHE_DIR" ]] || mkdir -p "$CACHE_DIR" 2>/dev/null

# ── path token ──────────────────────────────────────────────────
# %~ -style abbreviation without invoking the prompt expander.
local pretty="${PWD/#$HOME/~}"

# ── git repo detection (fast, no network) ───────────────────────
local git_root branch
git_root=$(command git rev-parse --show-toplevel 2>/dev/null)

if [[ -z "$git_root" ]]; then
  herdr workspace report-metadata "$WS" --source "$SOURCE" \
    --token "path=$pretty" --clear-token pr --ttl-ms "$TTL_MS" >/dev/null 2>&1
  return 0
fi

branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
  || branch=$(command git rev-parse --short HEAD 2>/dev/null)

# ── PR token: served from cache, refreshed in background ────────
local key="${git_root}::${branch}"
local cache_file="$CACHE_DIR/$(printf '%s' "$key" | command shasum -a 1 | cut -d' ' -f1)"

local pr_text=""
[[ -f "$cache_file" ]] && pr_text=$(<"$cache_file")

# Is the cache missing or stale? If so, kick off a detached refresh.
local need_refresh=1
if [[ -f "$cache_file" ]]; then
  local age=$(( $(date +%s) - $(command stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
  (( age < PR_CACHE_TTL )) && need_refresh=0
fi

if (( need_refresh )) && command -v gh >/dev/null 2>&1; then
  # Detached, output discarded: the prompt must never wait on this.
  (
    local out
    out=$(cd "$git_root" && command gh pr view --json number,state,isDraft,additions,deletions,changedFiles \
            --jq '"#\(.number) \(if .isDraft then "DRAFT" else .state end)  +\(.additions) -\(.deletions)  \(.changedFiles)f"' \
          2>/dev/null)
    if [[ -z "$out" ]]; then
      # No PR for this branch - show how far ahead of upstream we are instead.
      local ahead
      ahead=$(cd "$git_root" && command git rev-list --count @{upstream}..HEAD 2>/dev/null)
      if [[ -n "$ahead" && "$ahead" != "0" ]]; then
        out="no PR  ↑${ahead}"
      else
        out="no PR"
      fi
    fi
    printf '%s' "$out" >| "$cache_file"
  ) >/dev/null 2>&1 &!
fi

if [[ -n "$pr_text" ]]; then
  herdr workspace report-metadata "$WS" --source "$SOURCE" \
    --token "path=$pretty" --token "pr=$pr_text" --ttl-ms "$TTL_MS" >/dev/null 2>&1
else
  herdr workspace report-metadata "$WS" --source "$SOURCE" \
    --token "path=$pretty" --ttl-ms "$TTL_MS" >/dev/null 2>&1
fi

# ── top-of-window context: name the tab after the repo/dir ──────
if [[ -n "$HERDR_TAB_ID" ]]; then
  herdr tab rename "$HERDR_TAB_ID" "${git_root:t}" >/dev/null 2>&1
fi

return 0
