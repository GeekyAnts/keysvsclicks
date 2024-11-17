//
//  ContentView.swift
//  KeysVsClicks
//
//  Created by Sanket Sahu on 17/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var inputMonitor = InputMonitor()
    @State private var isTracking = false
    
    private var keyClickRatio: String {
        if inputMonitor.clickCount == 0 {
            return "0.00"
        }
        let ratio = Double(inputMonitor.keyCount) / Double(inputMonitor.clickCount)
        return String(format: "%.2f", ratio)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            VStack(spacing: 16) {
                if !inputMonitor.hasPermission {
                    Text("Input Monitoring Permission Required")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Button(isTracking ? "Stop Tracking" : "Start Tracking") {
                    isTracking.toggle()
                    if isTracking {
                        inputMonitor.startMonitoring()
                    } else {
                        inputMonitor.stopMonitoring()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!inputMonitor.hasPermission)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 32)
            .background(
                ZStack(alignment: .bottomTrailing) {
                    Color(NSColor.windowBackgroundColor)
                    
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .offset(y: 20)
                        .opacity(0.15)
                }
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
            
            // Scrollable Content
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    Text("Keys vs Clicks")
                        .font(.largeTitle)
                        .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text("KeyClickRatio")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(keyClickRatio)
                            .font(.system(size: 72, weight: .bold))
                        Text("keys per click")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    .frame(width: 400)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(15)

                    HStack(spacing: 40) {
                        VStack {
                            Text("Keyboard")
                                .font(.title3)
                            Text("\(inputMonitor.keyCount)")
                                .font(.system(size: 40, weight: .medium))
                        }
                        .frame(width: 180, height: 120)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        
                        VStack {
                            Text("Mouse")
                                .font(.title3)
                            Text("\(inputMonitor.clickCount)")
                                .font(.system(size: 40, weight: .medium))
                        }
                        .frame(width: 180, height: 120)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    

                    
                    Text(isTracking ? "Currently tracking your input usage" : "Start tracking your input usage")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
