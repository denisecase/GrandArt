import AppKit
import SwiftUI

/// `WelcomeWindowController` is a subclass of `NSWindowController` that manages the welcome window in the GrandArt
/// application.
@available(macOS 12.0, *)
class WelcomeWindowController: NSWindowController {
  // The AppState instance managing the application's state.
  var appState: AppState

  /// Initializes a new WelcomeWindowController with the given AppState.
  /// - Parameter appState: The application state to be used.
  init(appState: AppState) {
    self.appState = appState
    let width = GrandArtApp.AppConstants.defaultWidth()
    let height = GrandArtApp.AppConstants.defaultHeight()
    let minW = GrandArtApp.AppConstants.minWelcomeWidth
    let minH = GrandArtApp.AppConstants.minWelcomeHeight
    let maxW = GrandArtApp.AppConstants.maxWelcomeWidth()
    let maxH = GrandArtApp.AppConstants.maxWelcomeHeight()

    let window = NSWindow(
      contentRect: NSRect(
        x: 0, y: 0,
        width: width,
        height: height
      ),
      styleMask: [.titled, .closable, .resizable],
      backing: .buffered, defer: false
    )

    super.init(window: window)

    window.center()
    window.setFrameAutosaveName("Welcome Window")
    window.minSize = NSSize(width: minW, height: minH)
    window.maxSize = NSSize(width: maxW, height: maxH)

    window.contentView = NSHostingView(rootView: WelcomeView().environmentObject(self.appState))
  }

  /// Required initializer for NSCoder, not implemented for this class.
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
