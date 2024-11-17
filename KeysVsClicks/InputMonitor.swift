import Foundation
import CoreGraphics
import AppKit

class InputMonitor: ObservableObject {
    @Published var keyCount: Int = 0
    @Published var clickCount: Int = 0
    @Published var hasPermission: Bool = false
    
    private var keyboardTap: CFMachPort?
    private var mouseTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isMonitoring = false
    
    init() {
        loadCounts()
        checkPermissions()
    }
    
    private func loadCounts() {
        DispatchQueue.main.async {
            self.keyCount = UserDefaults.standard.integer(forKey: "keyCount")
            self.clickCount = UserDefaults.standard.integer(forKey: "clickCount")
        }
    }
    
    private func saveCounts() {
        DispatchQueue.main.async {
            UserDefaults.standard.set(self.keyCount, forKey: "keyCount")
            UserDefaults.standard.set(self.clickCount, forKey: "clickCount")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func checkPermissions() {
        let options = CGEventTapOptions.defaultTap
        let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: options,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        
        hasPermission = tap != nil
    }
    
    private func requestPermissions() {
        let alert = NSAlert()
        alert.messageText = "Input Monitoring Permission Required"
        alert.informativeText = """
            KeysVsClicks needs Input Monitoring permission to count keystrokes and clicks.

            1. Click "Open Settings" below
            2. Click the lock icon to make changes
            3. Find "KeysVsClicks" in the list
            4. Check the box next to KeysVsClicks
            5. Restart the app
            
            If KeysVsClicks is not in the list, please quit the app and relaunch it.
            """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            // Try to open directly to Input Monitoring with the correct bundle ID
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                NSWorkspace.shared.open(url)
                
                // Show follow-up alert about restarting
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let restartAlert = NSAlert()
                    restartAlert.messageText = "Please Restart App"
                    restartAlert.informativeText = "After enabling the permission for KeysVsClicks, please quit and relaunch the app for the changes to take effect."
                    restartAlert.alertStyle = .informational
                    restartAlert.addButton(withTitle: "OK")
                    restartAlert.runModal()
                }
            }
        }
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        // Force a new permission check
        checkPermissions()
        
        // If no permission, try to create a test tap to trigger system prompt
        if !hasPermission {
            let testTap = CGEvent.tapCreate(
                tap: .cghidEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
                callback: { _, _, event, _ in Unmanaged.passRetained(event) },
                userInfo: nil
            )
            
            if testTap == nil {
                requestPermissions()
                return
            }
        }
        
        // Monitor keyboard events
        keyboardTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { (_, _, event, refcon) in
                if let monitor = Unmanaged<InputMonitor>.fromOpaque(refcon!).takeUnretainedValue() as? InputMonitor {
                    DispatchQueue.main.async {
                        monitor.keyCount += 1
                        monitor.saveCounts()
                    }
                }
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        // Monitor mouse events
        mouseTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.leftMouseDown.rawValue) |
                            CGEventMask(1 << CGEventType.rightMouseDown.rawValue),
            callback: { (_, _, event, refcon) in
                if let monitor = Unmanaged<InputMonitor>.fromOpaque(refcon!).takeUnretainedValue() as? InputMonitor {
                    DispatchQueue.main.async {
                        monitor.clickCount += 1
                        monitor.saveCounts()
                    }
                }
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        if let keyboardTap = keyboardTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyboardTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: keyboardTap, enable: true)
            self.runLoopSource = runLoopSource
        }
        
        if let mouseTap = mouseTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: mouseTap, enable: true)
        }
        
        isMonitoring = true
    }
    
    func stopMonitoring() {
        if let keyboardTap = keyboardTap {
            CGEvent.tapEnable(tap: keyboardTap, enable: false)
        }
        if let mouseTap = mouseTap {
            CGEvent.tapEnable(tap: mouseTap, enable: false)
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        
        isMonitoring = false
        saveCounts()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func requestInputMonitoringPermission() {
        // Try to create a test event tap to check permissions
        let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        
        if eventTap == nil {
            let alert = NSAlert()
            alert.messageText = "Input Monitoring Permission Required"
            alert.informativeText = "This app needs Input Monitoring permission to count your keystrokes and clicks. Please grant permission in System Settings > Privacy & Security > Input Monitoring."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            // Clean up the test tap if it was created
            if let tap = eventTap {
                CFMachPortInvalidate(tap)
            }
        }
    }
} 