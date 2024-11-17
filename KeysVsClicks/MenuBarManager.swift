import SwiftUI
import AppKit

class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private var window: NSWindow?
    private var windowController: WindowController?
    
    override init() {
        super.init()
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            if let image = NSImage(named: "AppIcon") {
                image.size = NSSize(width: 16, height: 16)
                button.image = image
            }
        }
        
        let menu = NSMenu()
        let openItem = NSMenuItem(title: "Open", action: #selector(openWindow), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc public func openWindow() {
        NSApp.setActivationPolicy(.regular)
        
        if let windowController = self.windowController {
            windowController.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let contentView = ContentView()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.title = "Keys vs Clicks"
        
        let windowController = WindowController(window: window)
        self.windowController = windowController
        windowController.showWindow(nil)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quit() {
        NSApp.terminate(nil)
    }
} 