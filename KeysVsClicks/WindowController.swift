import SwiftUI

class WindowController: NSWindowController {
    convenience init() {
        let contentView = NSHostingController(rootView: ContentView())
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 750),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Keys vs Clicks"
        window.minSize = NSSize(width: 500, height: 600)
        window.contentViewController = contentView
        window.isReleasedWhenClosed = false
        
        self.init(window: window)
        
        window.delegate = WindowDelegate.shared
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.center()
    }
}

class WindowDelegate: NSObject, NSWindowDelegate {
    static let shared = WindowDelegate()
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
} 