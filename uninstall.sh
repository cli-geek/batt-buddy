#!/usr/bin/env bash
set -euo pipefail

label="local.batt-buddy"
plist="$HOME/Library/LaunchAgents/$label.plist"

launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
rm -f "$plist"
echo "removed $label"
