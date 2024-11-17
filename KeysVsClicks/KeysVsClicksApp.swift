//
//  KeysVsClicksApp.swift
//  KeysVsClicks
//
//  Created by Sanket Sahu on 17/11/24.
//

import SwiftUI

@main
struct KeysVsClicksApp: App {
    var windowController: WindowController?
    
    init() {
        windowController = WindowController()
        windowController?.window?.center()
        windowController?.showWindow(nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        
        MenuBarExtra("Keys vs Clicks", systemImage: "keyboard") {
            ContentView()
        }
    }
}
