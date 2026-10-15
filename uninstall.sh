#!/usr/bin/env bash
set -euo pipefail

main() {
  local label="local.batt-buddy"
  local plist="$HOME/Library/LaunchAgents/$label.plist"

  launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
  rm -f "$plist"
  # Created only by a curl-piped install; a clone keeps its own binary.
  rm -rf "$HOME/.local/share/batt-buddy"
  echo "removed $label"
}

main "$@"
