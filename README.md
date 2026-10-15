# batt-buddy

A tiny macOS menu bar item that shows the estimated battery time remaining,
e.g. `3:42`. It hides itself while the Mac is on AC power and reappears when
you unplug.

macOS stopped showing the time remaining in the menu bar battery icon in
10.12.2. batt-buddy brings back just that one number.

- One Swift file, no dependencies beyond what ships with macOS.
- Reads the estimate from IOKit (`IOPSGetTimeRemainingEstimate`), the same
  source `pmset -g batt` reports.
- Updates on power-source change notifications, plus a 60-second refresh.
- No Dock icon, no window. Click the time for a Quit menu.

## Install

Requirements: macOS with the Xcode Command Line Tools (for `swiftc`). If
`xcrun --find swiftc` fails, run `xcode-select --install` first.

```sh
git clone <repo-url> batt-buddy
cd batt-buddy
./install.sh
```

`install.sh` compiles `main.swift` to `./batt-buddy` and loads a per-user
LaunchAgent at `~/Library/LaunchAgents/local.batt-buddy.plist`, so it starts
at every login. The agent points at the binary in the clone, so keep the clone
where it is (or rerun `install.sh` after moving it).

After changing the code, run `./install.sh` again to rebuild and reload.

## Uninstall

```sh
./uninstall.sh
```

This stops the agent and removes the plist. Delete the clone to remove the
binary.

## FAQ

**I don't see anything in the menu bar.**
You are probably on AC power, where the item is hidden by design. Unplug to
check. If it still doesn't appear, confirm it is running with
`launchctl print gui/$(id -u)/local.batt-buddy`.

**It shows `--:--`.**
macOS hasn't calculated an estimate yet. This happens for roughly the first
minute after unplugging. `pmset -g batt` shows `(no estimate)` at the same time.

**How do I quit it?**
Click the time and choose Quit. It stays stopped until your next login or
until you rerun `./install.sh`. If it crashes, launchd restarts it.

**Why IOKit instead of parsing `pmset -g batt`?**
`pmset` reads the same IOKit value. Calling the API directly avoids spawning
a process and parsing text, and lets the app react to plug/unplug events
immediately instead of polling.

**Does it use much battery?**
No. It sleeps until a power-source notification or the once-a-minute timer
fires, then reads one value.

**Which macOS versions does it support?**
It has been built and run only on macOS Monterey 12.7.6 (Intel). The APIs it
uses are old and stable, so other versions will probably work, but that hasn't
been tested.

## License

MIT. See [LICENSE](LICENSE).

## AI usage attestation

The code, scripts, and this README were written by Claude (Anthropic,
model Opus 5.5) through Claude Code, at the direction of the repository owner.
The owner specified the requirements and reviewed the result.
