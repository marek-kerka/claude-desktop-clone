//
//  ContentView.swift
//  LivesportClaude
//

import SwiftUI

struct ContentView: View {
    @StateObject private var storage = ConversationStorage()
    @StateObject private var promptStorage = SystemPromptStorage()
    @StateObject private var searchService = SearchService()

    @State private var selectedConversation: Conversation?
    @State private var showingSettings = false
    @State private var showingSearch = false

    var body: some View {
        NavigationSplitView {
            // Sidebar
            ConversationListView(
                storage: storage,
                selectedConversation: $selectedConversation
            )
            .frame(minWidth: 250, idealWidth: 300)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
        } detail: {
            // Main content
            if let conversation = selectedConversation,
               let index = storage.conversations.firstIndex(where: { $0.id == conversation.id }) {
                ChatView(
                    conversation: $storage.conversations[index],
                    storage: storage,
                    promptStorage: promptStorage
                )
                .id(conversation.id)
            } else {
                WelcomeView()
            }
        }
        .navigationTitle(AppConfiguration.appName)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showingSearch = true }) {
                    Image(systemName: "magnifyingglass")
                }
                .help("Search conversations")
            }

            ToolbarItem(placement: .automatic) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                }
                .help("Settings")
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(storage: storage, promptStorage: promptStorage)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(
                searchService: searchService,
                storage: storage,
                selectedConversation: $selectedConversation
            )
        }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("Welcome to \(AppConfiguration.appName)")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Built for Livesport employees")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "cpu", title: "Claude Sonnet 4.5", description: "Fast and intelligent responses")
                FeatureRow(icon: "brain", title: "Claude Opus 4.5", description: "Advanced reasoning capabilities")
                FeatureRow(icon: "photo", title: "Image Support", description: "Attach and analyze images")
                FeatureRow(icon: "bubble.left.and.bubble.right", title: "Conversation History", description: "All your chats saved locally")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)

            Text("Click the + button in the sidebar to start a new conversation")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: 500)
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
