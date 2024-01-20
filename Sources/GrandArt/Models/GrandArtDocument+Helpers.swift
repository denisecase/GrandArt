import Foundation
import SwiftUI

@available(macOS 12.0, *)
extension GrandArtDocument {
  var currentWindowTitle: String {
    return NSApp.mainWindow?.title ?? ""
  }

  var dataFileName: String {
    return baseFileName + Constants.dotGrandart
  }

  var imageFileName: String {
    return baseFileName + Constants.dotPng
  }

  private var baseFileName: String {
    let title = currentWindowTitle.isEmpty ? "MyArt" : currentWindowTitle

    // Strip off the extension if it exists
    if title.hasSuffix(Constants.dotGrandart) {
      return title.replacingOccurrences(of: Constants.dotGrandart, with: "")
    }
    return title
  }

  var userCGColorList: [CGColor] {
    return picdef.hues.map { hue in
      CGColor(red: CGFloat(hue.r / 255.0), green: CGFloat(hue.g / 255.0), blue: CGFloat(hue.b / 255.0), alpha: 1.0)
    }
  }

  func handleError(_ error: GrandArtError) {
    print(error.localizedDescription)
    // Here you can also display an alert to the user or handle the error in other ways
    // For now, we will just log and exit the application
    NSApplication.shared.windows.forEach { $0.close() }
    NSApplication.shared.terminate(nil)
  }
}
