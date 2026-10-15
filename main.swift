import AppKit
import IOKit.ps

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
let menu = NSMenu()
menu.addItem(NSMenuItem(title: "Quit batt-buddy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
item.menu = menu

func refresh() {
  let seconds = IOPSGetTimeRemainingEstimate()
  // -2 = kIOPSTimeRemainingUnlimited (on AC), -1 = kIOPSTimeRemainingUnknown;
  // the C macros don't import into Swift.
  item.isVisible = seconds != -2
  if seconds == -1 {
    item.button?.title = "--:--"
  } else if seconds >= 0 {
    let minutes = Int(seconds) / 60
    item.button?.title = String(format: "%d:%02d", minutes / 60, minutes % 60)
  }
}

let source = IOPSNotificationCreateRunLoopSource({ _ in refresh() }, nil).takeRetainedValue()
CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
// Power-source notifications don't fire on every estimate change.
Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in refresh() }
refresh()
app.run()
