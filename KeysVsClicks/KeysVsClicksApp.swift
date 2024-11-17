//
//  KeysVsClicksApp.swift
//  KeysVsClicks
//
//  Created by Sanket Sahu on 17/11/24.
//

import SwiftUI

@main
struct KeysVsClicksApp: App {
    @State private var isWindowShown = false
    var windowController: WindowController?
    
    init() {
        windowController = WindowController()
        windowController?.window?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    var body: some Scene {
        MenuBarExtra(isInserted: .constant(true)) {
            Button("Open Keys vs Clicks") {
                isWindowShown = true
                windowController?.window?.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            
            Divider()
            
            Button("About Keys vs Clicks") {
                NSApplication.shared.orderFrontStandardAboutPanel(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            if let image = NSImage(named: "AppIcon") {
                // Scale down the app icon to fit in menu bar
                let scaledImage = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
                    image.draw(in: rect)
                    return true
                }
                Image(nsImage: scaledImage)
            }
        }
    }
}
