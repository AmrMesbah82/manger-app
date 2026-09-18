import Cocoa
import FlutterMacOS

// Ported from wash_application/macos/Runner/MainFlutterWindow.swift.
class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    // OPENING SIZE
    // MainMenu.xib opens at 800x600, which is too small for the admin/teacher
    // console (side rail + tables). Open at a real desktop size instead.
    let defaultSize = NSSize(width: 1440, height: 900)

    // MINIMUM SIZE
    //
    // Different from wash on purpose. In wash, narrowing the window swapped to
    // the customer app, so it had to shrink to 380. In Manger Plus a Mac is
    // ALWAYS the console (the device kind comes from the platform, not the
    // width — see PlatformHelper), so a release build keeps room for the rail
    // and a table: 960 x 640.
    //
    // DEBUG builds allow 380 x 480, so the student / parent apps can be
    // previewed at phone size through "Preview anyway" on the wrong-device
    // screen.
    //
    // `contentMinSize`, not `minSize`: `minSize` includes the title bar, so the
    // number would not be the width Flutter's LayoutBuilder actually sees.
    #if DEBUG
    let minimumContentSize = NSSize(width: 380, height: 480)
    #else
    let minimumContentSize = NSSize(width: 960, height: 640)
    #endif

    var windowFrame = self.frame
    windowFrame.size = defaultSize

    // Centre on whichever screen the window opened on, so it does not start
    // half off-screen on a laptop display.
    if let screen = self.screen ?? NSScreen.main {
      let visible = screen.visibleFrame
      windowFrame.origin = NSPoint(
        x: visible.midX - defaultSize.width / 2,
        y: visible.midY - defaultSize.height / 2
      )
    }

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.contentMinSize = minimumContentSize

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
