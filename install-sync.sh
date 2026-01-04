#!/bin/bash
# ┌──────────────────────────────────────────────────────────────┐
# │  INSTALL/REINSTALL AUTO-SYNC AGENT                           │
# │  Run this after modifying sync.sh or the plist               │
# └──────────────────────────────────────────────────────────────┘

set -e

PLIST_NAME="com.mradulsingh.unixrc-sync"
PLIST_SRC="$HOME/unixrc/com.mradulsingh.unixrc-sync.plist"
PLIST_DST="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"

echo "🔄 Reinstalling unixrc auto-sync agent..."

# Unload existing agent (ignore errors if not loaded)
launchctl unload "$PLIST_DST" 2>/dev/null || true
echo "   ✓ Unloaded existing agent"

# Copy plist to LaunchAgents
cp "$PLIST_SRC" "$PLIST_DST"
echo "   ✓ Copied plist to LaunchAgents"

# Ensure sync script is executable
chmod +x "$HOME/unixrc/sync.sh"
echo "   ✓ Made sync.sh executable"

# Load the new agent
launchctl load "$PLIST_DST"
echo "   ✓ Loaded new agent"

# Verify
if launchctl list | grep -q "$PLIST_NAME"; then
    echo ""
    echo "✅ Auto-sync agent installed successfully!"
    echo ""
    echo "Commands:"
    echo "  View log:    tail -f ~/unixrc/.sync.log"
    echo "  Stop:        launchctl unload $PLIST_DST"
    echo "  Start:       launchctl load $PLIST_DST"
    echo "  Manual sync: ~/unixrc/sync.sh"
else
    echo ""
    echo "❌ Failed to install agent"
    exit 1
fi
