//
//  SettingsView.swift
//  LivesportClaude
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedModel") private var selectedModel: String = ClaudeModel.sonnet.rawValue
    @AppStorage("systemPrompt") private var systemPrompt: String = AppConfiguration.defaultSystemPrompt
    @ObservedObject var storage: ConversationStorage

    @State private var showingClearConfirmation = false

    var body: some View {
        Form {
            Section("API Configuration") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key Status")
                        .font(.headline)

                    HStack {
                        Image(systemName: AppConfiguration.claudeAPIKey.contains("YOUR_") ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundColor(AppConfiguration.claudeAPIKey.contains("YOUR_") ? .orange : .green)

                        Text(AppConfiguration.claudeAPIKey.contains("YOUR_") ? "Not configured" : "Configured")
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
            }

            Section("System Prompt") {
                TextEditor(text: $systemPrompt)
                    .frame(minHeight: 100)
                    .font(.system(.body, design: .monospaced))

                Button("Reset to Default") {
                    systemPrompt = AppConfiguration.defaultSystemPrompt
                }
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

            Section("About") {
                LabeledContent("App Name", value: AppConfiguration.appName)
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Built for", value: "Livesport")
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 600)
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
