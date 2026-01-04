#!/bin/bash
# ┌──────────────────────────────────────────────────────────────┐
# │  UNIXRC AUTO-SYNC SCRIPT                                     │
# │  Triggered by launchd when config files change               │
# └──────────────────────────────────────────────────────────────┘

set -e

REPO_DIR="$HOME/unixrc"
LOG_FILE="$REPO_DIR/.sync.log"

# Timestamp for logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "Sync triggered"

# Change to repo directory
cd "$REPO_DIR"

# Track if anything changed
CHANGED=false

# Sync Ghostty config
if ! diff -q "$HOME/.config/ghostty/config" "$REPO_DIR/ghostty/config" > /dev/null 2>&1; then
    cp "$HOME/.config/ghostty/config" "$REPO_DIR/ghostty/config"
    log "Synced: ghostty/config"
    CHANGED=true
fi

# Sync Tmux config
if ! diff -q "$HOME/.tmux.conf" "$REPO_DIR/tmux/tmux.conf" > /dev/null 2>&1; then
    cp "$HOME/.tmux.conf" "$REPO_DIR/tmux/tmux.conf"
    log "Synced: tmux/tmux.conf"
    CHANGED=true
fi

# Sync Neovim config (check each file)
NVIM_SRC="$HOME/.config/nvim"
NVIM_DST="$REPO_DIR/nvim"

# Files to sync (excluding .git, lazy data, etc.)
NVIM_FILES=(
    "init.lua"
    "lazy-lock.json"
    "lazyvim.json"
    "stylua.toml"
    "lua/config/autocmds.lua"
    "lua/config/keymaps.lua"
    "lua/config/lazy.lua"
    "lua/config/options.lua"
)

# Sync nvim plugin files dynamically
for plugin_file in "$NVIM_SRC/lua/plugins/"*.lua; do
    if [[ -f "$plugin_file" ]]; then
        filename=$(basename "$plugin_file")
        NVIM_FILES+=("lua/plugins/$filename")
    fi
done

for file in "${NVIM_FILES[@]}"; do
    src="$NVIM_SRC/$file"
    dst="$NVIM_DST/$file"

    if [[ -f "$src" ]]; then
        # Create directory if needed
        mkdir -p "$(dirname "$dst")"

        if ! diff -q "$src" "$dst" > /dev/null 2>&1; then
            cp "$src" "$dst"
            log "Synced: nvim/$file"
            CHANGED=true
        fi
    fi
done

# If nothing changed, exit
if [[ "$CHANGED" == "false" ]]; then
    log "No changes detected"
    exit 0
fi

# Git add, commit, and push
git add -A

# Check if there are staged changes
if git diff --cached --quiet; then
    log "No git changes to commit"
    exit 0
fi

# Generate commit message based on what changed
COMMIT_MSG="Auto-sync: $(date '+%Y-%m-%d %H:%M')"

# --no-gpg-sign: GPG may not be available in launchd environment
git commit --no-gpg-sign -m "$COMMIT_MSG"
log "Committed: $COMMIT_MSG"

# Push to remote
if git push origin master 2>> "$LOG_FILE"; then
    log "Pushed to GitHub successfully"
else
    log "ERROR: Push failed"
    exit 1
fi

log "Sync completed successfully"
