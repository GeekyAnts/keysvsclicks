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
    }
    
    var body: some Scene {
        MenuBarExtra("Keys vs Clicks", systemImage: "keyboard") {
            Button("Open Keys vs Clicks") {
                isWindowShown = true
                windowController?.window?.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
