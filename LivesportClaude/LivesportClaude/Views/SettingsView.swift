//
//  SettingsView.swift
//  LivesportClaude
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedModel") private var selectedModel: String = ClaudeModel.sonnet.rawValue
    @ObservedObject var storage: ConversationStorage
    @ObservedObject var promptStorage: SystemPromptStorage

    @State private var showingClearConfirmation = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView(
                selectedModel: $selectedModel,
                storage: storage,
                showingClearConfirmation: $showingClearConfirmation
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            .tag(0)

            SystemPromptsView(promptStorage: promptStorage)
                .tabItem {
                    Label("System Prompts", systemImage: "text.bubble")
                }
                .tag(1)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
        }
        .frame(width: 700, height: 600)
    }
}

struct GeneralSettingsView: View {
    @Binding var selectedModel: String
    @ObservedObject var storage: ConversationStorage
    @Binding var showingClearConfirmation: Bool
    @AppStorage("appearanceMode") private var appearanceMode: String = AppearanceMode.system.rawValue

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        VStack(alignment: .leading) {
                            Text(mode.displayName)
                            Text(mode.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(mode.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)

                Text("Change the appearance of the application")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("API Configuration") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key Status")
                        .font(.headline)

                    HStack {
                        let isConfigured = !AppConfiguration.claudeAPIKey.contains("YOUR_")
                        Image(systemName: isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(isConfigured ? .green : .orange)

                        Text(isConfigured ? "Configured" : "Not configured")
                            .foregroundColor(.secondary)
                    }

                    if AppConfiguration.claudeAPIKey.contains("YOUR_") {
                        Text("Edit AppConfiguration.swift to set your API key")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }

            Section("Default Model") {
                Picker("Model", selection: $selectedModel) {
                    ForEach(ClaudeModel.allCases) { model in
                        VStack(alignment: .leading) {
                            Text(model.displayName)
                            Text(model.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(model.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)

                Text("This sets the default model for new conversations")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Data") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Stored Conversations")
                            .font(.headline)
                        Text("\(storage.conversations.count) conversation(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button("Clear All", role: .destructive) {
                        showingClearConfirmation = true
                    }
                    .disabled(storage.conversations.isEmpty)
                }
            }
        }
        .formStyle(.grouped)
        .alert("Clear All Conversations?", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                storage.deleteAllConversations()
            }
        } message: {
            Text("This will permanently delete all conversations. This action cannot be undone.")
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text(AppConfiguration.appName)
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()
                .padding(.horizontal, 100)

            VStack(spacing: 16) {
                InfoRow(title: "Built for", value: "Livesport")
                InfoRow(title: "Platform", value: "macOS 13.0+")
                InfoRow(title: "Framework", value: "SwiftUI")
                InfoRow(title: "AI Provider", value: "Anthropic Claude")
            }

            Spacer()

            VStack(spacing: 4) {
                Text("© 2024 Livesport s.r.o.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("For internal use only")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 100)
    }
}
