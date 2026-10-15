# batt-buddy

A tiny macOS menu bar item that shows the estimated battery time remaining,
e.g. `3:42 left`. It hides itself while the Mac is on AC power and reappears when
you unplug.

macOS stopped showing the time remaining in the menu bar battery icon in
10.12.2. batt-buddy brings back just that one number.

- One Swift file, no dependencies beyond what ships with macOS.
- Reads the estimate from IOKit (`IOPSGetTimeRemainingEstimate`), the same
  source `pmset -g batt` reports.
- Updates on power-source change notifications, plus a 60-second refresh.
- No Dock icon, no window. Click the time for a menu with the full
  "3:42 remaining" line and Quit.

## Install

Requirements: macOS with the Xcode Command Line Tools (for `swiftc`). The
installer checks for them and, if they are missing, tells you to run
`xcode-select --install`.

### One line

```sh
curl -fsSL https://raw.githubusercontent.com/cli-geek/batt-buddy/main/install.sh | bash
```

This downloads `main.swift` to `~/.local/share/batt-buddy`, compiles it there,
and loads a per-user LaunchAgent at
`~/Library/LaunchAgents/local.batt-buddy.plist`, so it starts at every login.

Piping a script into `bash` runs it without showing it to you first. To read
it before running it:

```sh
curl -fsSL https://raw.githubusercontent.com/cli-geek/batt-buddy/main/install.sh -o install.sh
less install.sh
bash install.sh
```

### From a clone

```sh
git clone https://github.com/cli-geek/batt-buddy.git
cd batt-buddy
./install.sh
```

Run from a clone, the installer builds `./batt-buddy` in place and the agent
points at it, so keep the clone where it is (or rerun `install.sh` after
moving it). After changing the code, run `./install.sh` again to rebuild and
reload.

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/cli-geek/batt-buddy/main/uninstall.sh | bash
```

or `./uninstall.sh` from a clone. This stops the agent, removes the plist, and
deletes `~/.local/share/batt-buddy`. A clone is left alone; delete it yourself
to remove that copy.

## FAQ

**I don't see anything in the menu bar.**
You are probably on AC power, where the item is hidden by design. Unplug to
check. If it still doesn't appear, confirm it is running with
`launchctl print gui/$(id -u)/local.batt-buddy`.

**It shows `--:--`.**
macOS hasn't calculated an estimate yet. This happens for roughly the first
minute after unplugging. `pmset -g batt` shows `(no estimate)` at the same time.

**Can I move it next to the battery icon?**
Hold Cmd and drag it along the menu bar. macOS remembers the position across
restarts. Apps can't choose their own spot in the menu bar, so this has to be
done by hand.

**How do I quit it?**
Click the time and choose Quit. It stays stopped until your next login or
until you rerun the installer. If it crashes, launchd restarts it.

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

This program and its documentation were created with AI assistance.
Requirements specified at the discretion of cli-geek. Output reviewed and
verified.
