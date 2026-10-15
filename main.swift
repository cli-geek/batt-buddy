import AppKit
import IOKit.ps

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
// Lets macOS remember where the user Cmd-drags the item across launches.
item.autosaveName = "batt-buddy"
let remainingItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
remainingItem.isEnabled = false
let menu = NSMenu()
menu.autoenablesItems = false
menu.addItem(remainingItem)
menu.addItem(NSMenuItem.separator())
menu.addItem(NSMenuItem(title: "Quit batt-buddy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
item.menu = menu

func refresh() {
  let seconds = IOPSGetTimeRemainingEstimate()
  // -2 = kIOPSTimeRemainingUnlimited (on AC), -1 = kIOPSTimeRemainingUnknown;
  // the C macros don't import into Swift.
  item.isVisible = seconds != -2
  if seconds == -1 {
    item.button?.title = "--:--"
    remainingItem.title = "Calculating time remaining..."
  } else if seconds >= 0 {
    let minutes = Int(seconds) / 60
    let time = String(format: "%d:%02d", minutes / 60, minutes % 60)
    item.button?.title = "\(time) left"
    remainingItem.title = "\(time) remaining"
  }
}

let source = IOPSNotificationCreateRunLoopSource({ _ in refresh() }, nil).takeRetainedValue()
CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
// Power-source notifications don't fire on every estimate change.
Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in refresh() }
refresh()
app.run()
