import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    if ProcessInfo.processInfo.environment["PAPER_SHADERS_GOLDEN_TARGET"] != nil {
      styleMask = [.borderless]
      if let screenFrame = NSScreen.main?.visibleFrame {
        setFrame(
          NSRect(x: screenFrame.minX, y: screenFrame.maxY - 512, width: 512, height: 512),
          display: true
        )
      } else {
        setContentSize(NSSize(width: 512, height: 512))
      }
      backgroundColor = .black
      isOpaque = true
      level = .floating
      collectionBehavior = [.canJoinAllSpaces, .stationary]
      NSApp.activate(ignoringOtherApps: true)
      makeKeyAndOrderFront(nil)
      orderFrontRegardless()
    }
  }
}
