# batt-buddy

Battery time remaining in your macOS menu bar, like `3:42 left`. 

Unplug and it shows up; plug in and it gets out of the way.

macOS dropped the time estimate from its battery menu in **10.12.2**. This puts it
back, and does **nothing else**.

- One Swift file. No dependencies beyond macOS itself.
- Updates when the power source changes, and once per minute.
- No Dock icon or window. Click the time for "3:42 remaining", a Start at
  login toggle, and Quit.

## Install

You need the Xcode Command Line Tools for `swiftc`. The installer checks and
tells you to run `xcode-select --install` if they're missing.

```sh
curl -fsSL https://raw.githubusercontent.com/cli-geek/batt-buddy/main/install.sh | bash
```

That downloads `main.swift` to `~/.local/share/batt-buddy`, builds it, and
registers a LaunchAgent (`~/Library/LaunchAgents/local.batt-buddy.plist`) so
it starts at login.

Prefer to read a script before running it? Fair enough:

```sh
curl -fsSL https://raw.githubusercontent.com/cli-geek/batt-buddy/main/install.sh -o install.sh
less install.sh
bash install.sh
```

Or from a clone:

```sh
git clone https://github.com/cli-geek/batt-buddy.git
cd batt-buddy
./install.sh
```

A clone builds `./batt-buddy` in place and the agent runs it from there, so
rerun `./install.sh` if you move the clone or change the code.

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/cli-geek/batt-buddy/main/uninstall.sh | bash
```

Or `./uninstall.sh` from a clone. It stops the agent and removes the plist and
`~/.local/share/batt-buddy`. Your clone, if you have one, is left alone.

## FAQ

**Nothing in the menu bar.**  
You're probably plugged in; it hides on AC power. Unplug to check. Still
nothing? See if it's running: `launchctl print gui/$(id -u)/local.batt-buddy`.

**It says `--:--`.**  
macOS is still working out an estimate, which takes about a minute after you
unplug.

**Can it sit next to the battery icon?**  
Hold Cmd and drag it there. macOS remembers the spot.

**How do I quit it?**  
Click the time, choose Quit. It stays off until your next login or the next
install. If it crashes, launchd restarts it. To keep it from starting at login,
untick `Start at login` in the same menu.

**Battery cost?**  
Close to none. It sleeps until a power event or the one-minute timer, then
reads one number.

**Which macOS versions?**  
Built and tested on Monterey 12.7.6 (Intel) only. The APIs are old and
stable, so other versions will probably work, but it's untested.

## License

MIT. See [LICENSE](LICENSE).

## AI usage attestation

This program and its documentation were created with AI assistance.

Requirements specified at the discretion of cli-geek.

Output reviewed and verified.
