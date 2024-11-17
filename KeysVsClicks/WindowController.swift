import SwiftUI

class WindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 750), // Increased height
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Keys vs Clicks"
        window.minSize = NSSize(width: 500, height: 600)
        
        self.init(window: window)
    }
} 