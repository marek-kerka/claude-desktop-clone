//
//  LivesportClaudeApp.swift
//  LivesportClaude
//

import SwiftUI

@main
struct LivesportClaudeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Conversation") {
                    // This will be handled by the ContentView
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }

        Settings {
            SettingsView(storage: ConversationStorage())
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app appearance
        if let window = NSApplication.shared.windows.first {
            window.titlebarAppearsTransparent = false
            window.titleVisibility = .visible
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
