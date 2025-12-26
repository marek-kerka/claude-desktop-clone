//
//  LivesportClaudeApp.swift
//  LivesportClaude
//

import SwiftUI

@main
struct LivesportClaudeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("appearanceMode") private var appearanceMode: String = AppearanceMode.system.rawValue

    private var currentColorScheme: ColorScheme? {
        AppearanceMode(rawValue: appearanceMode)?.colorScheme
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .preferredColorScheme(currentColorScheme)
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
            SettingsView(
                storage: ConversationStorage(),
                promptStorage: SystemPromptStorage(),
                usageStorage: UsageStorage()
            )
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

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let dockMenu = NSMenu()

        // New Conversation
        let newConvItem = NSMenuItem(
            title: "New Conversation",
            action: #selector(newConversation),
            keyEquivalent: ""
        )
        newConvItem.target = self
        dockMenu.addItem(newConvItem)

        dockMenu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        dockMenu.addItem(settingsItem)

        return dockMenu
    }

    @objc func newConversation() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc func openSettings() {
        NSApplication.shared.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
