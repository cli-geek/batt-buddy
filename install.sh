#!/usr/bin/env bash
# Build batt-buddy and (re)load it as a per-user LaunchAgent that starts at login.
# Run from a clone, or piped from curl, in which case main.swift is downloaded
# to ~/.local/share/batt-buddy and built there.
set -euo pipefail

# Wrapped in a function so a truncated `curl | bash` download runs nothing.
main() {
  local source_url="https://raw.githubusercontent.com/cli-geek/batt-buddy/main/main.swift"
  local label="local.batt-buddy"
  local plist="$HOME/Library/LaunchAgents/$label.plist"
  local domain
  domain="gui/$(id -u)"

  # /usr/bin/swiftc exists even without the Command Line Tools; it is a shim
  # that pops an install dialog, so ask xcrun whether the real compiler exists.
  if ! xcrun --find swiftc >/dev/null 2>&1; then
    echo "swiftc not found. Install the Xcode Command Line Tools with:" >&2
    echo "  xcode-select --install" >&2
    echo "then rerun this installer." >&2
    exit 1
  fi

  local script_dir="" project_dir
  if [[ -f "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi
  if [[ -n "$script_dir" && -f "$script_dir/main.swift" ]]; then
    project_dir="$script_dir"
  else
    project_dir="$HOME/.local/share/batt-buddy"
    mkdir -p "$project_dir"
    curl -fsSL "$source_url" -o "$project_dir/main.swift"
  fi
  local binary="$project_dir/batt-buddy"

  swiftc -O "$project_dir/main.swift" -o "$binary"

  mkdir -p "$(dirname "$plist")"
  cat >"$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$binary</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <dict>
    <key>SuccessfulExit</key>
    <false/>
  </dict>
  <key>ProcessType</key>
  <string>Interactive</string>
</dict>
</plist>
EOF

  launchctl bootout "$domain/$label" 2>/dev/null || true
  launchctl bootstrap "$domain" "$plist"
  echo "loaded $label from $plist"
}

main "$@"
