#!/usr/bin/env bash
# Build batt-buddy and (re)load it as a per-user LaunchAgent that starts at login.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
binary="$project_dir/batt-buddy"
label="local.batt-buddy"
plist="$HOME/Library/LaunchAgents/$label.plist"
domain="gui/$(id -u)"

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
