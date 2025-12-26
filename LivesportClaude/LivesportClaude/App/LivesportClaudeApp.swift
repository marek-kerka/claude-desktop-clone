//
//  LivesportClaudeApp.swift
//  LivesportClaude
//

import SwiftUI

@main
struct LivesportClaudeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("appearanceMode") private var appearanceMode: String = AppearanceMode.system.rawValue
    @StateObject private var updateChecker = UpdateChecker.shared

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

            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updateChecker.checkForUpdates()
                }
                .disabled(!updateChecker.canCheckForUpdates || updateChecker.updateCheckInProgress)

                Divider()
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
    private var dockMenuCostCache: String = "$0.0000"
    private var dockMenuCallsCache: Int = 0
    private var recentConversationsCache: [(String, UUID)] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app appearance
        if let window = NSApplication.shared.windows.first {
            window.titlebarAppearsTransparent = false
            window.titleVisibility = .visible
        }

        // Update dock menu cache periodically
        Task { @MainActor in
            self.updateDockMenuCache()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @MainActor
    func updateDockMenuCache() {
        let usageStorage = UsageStorage.shared
        let conversationStorage = ConversationStorage.shared

        let todayStats = usageStorage.statistics.today
        dockMenuCostCache = String(format: "$%.4f", todayStats.totalCost)
        dockMenuCallsCache = todayStats.records.count

        recentConversationsCache = Array(conversationStorage.conversations.prefix(5))
            .map { ($0.title, $0.id) }
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        // Update cache before showing menu
        Task { @MainActor in
            self.updateDockMenuCache()
        }

        let dockMenu = NSMenu()

        // Today's cost and calls
        let costItem = NSMenuItem(
            title: "Today: \(dockMenuCostCache) (\(dockMenuCallsCache) calls)",
            action: nil,
            keyEquivalent: ""
        )
        costItem.isEnabled = false
        dockMenu.addItem(costItem)

        dockMenu.addItem(NSMenuItem.separator())

        // New Conversation
        let newConvItem = NSMenuItem(
            title: "New Conversation",
            action: #selector(newConversation),
            keyEquivalent: ""
        )
        newConvItem.target = self
        dockMenu.addItem(newConvItem)

        // Recent conversations
        if !recentConversationsCache.isEmpty {
            dockMenu.addItem(NSMenuItem.separator())

            let recentHeader = NSMenuItem(
                title: "Recent Conversations",
                action: nil,
                keyEquivalent: ""
            )
            recentHeader.isEnabled = false
            dockMenu.addItem(recentHeader)

            for (title, id) in recentConversationsCache {
                let convItem = NSMenuItem(
                    title: "  \(title)",
                    action: #selector(openRecentConversation(_:)),
                    keyEquivalent: ""
                )
                convItem.target = self
                convItem.representedObject = id
                dockMenu.addItem(convItem)
            }
        }

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

    @objc func openRecentConversation(_ sender: NSMenuItem) {
        guard let conversationId = sender.representedObject as? UUID else { return }

        // Activate the app and bring window to front
        NSApplication.shared.activate(ignoringOtherApps: true)
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
        }

        // Post notification to switch to this conversation
        NotificationCenter.default.post(
            name: NSNotification.Name("SwitchToConversation"),
            object: nil,
            userInfo: ["conversationId": conversationId]
        )
    }

    @objc func openSettings() {
        NSApplication.shared.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
