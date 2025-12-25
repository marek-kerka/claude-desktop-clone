//
//  ConversationListView.swift
//  LivesportClaude
//

import SwiftUI

struct ConversationListView: View {
    @ObservedObject var storage: ConversationStorage
    @Binding var selectedConversation: Conversation?
    @State private var showingNewConversationSheet = false
    @State private var selectedModel: ClaudeModel = .sonnet

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Conversations")
                    .font(.headline)
                Spacer()
                Menu {
                    Button("Sonnet 4.5") {
                        createNewConversation(model: .sonnet)
                    }
                    Button("Opus 4.5") {
                        createNewConversation(model: .opus)
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                } primaryAction: {
                    createNewConversation(model: .sonnet)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30, height: 30)
            }
            .padding()

            Divider()

            // Conversations list
            if storage.conversations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No conversations yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Click + to start a new chat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedConversation) {
                    ForEach(storage.conversations) { conversation in
                        ConversationRowView(conversation: conversation)
                            .tag(conversation)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    deleteConversation(conversation)
                                }
                            }
                    }
                }
                .listStyle(.sidebar)
            }
        }
    }

    private func createNewConversation(model: ClaudeModel) {
        let conversation = storage.createConversation(model: model)
        selectedConversation = conversation
    }

    private func deleteConversation(_ conversation: Conversation) {
        if selectedConversation?.id == conversation.id {
            selectedConversation = nil
        }
        storage.deleteConversation(conversation)
    }
}

// MARK: - Conversation Row

struct ConversationRowView: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(conversation.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                Spacer()

                // Model badge
                Text(conversation.model == .opus ? "O" : "S")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 14, height: 14)
                    .background(conversation.model == .opus ? Color.purple : Color.blue)
                    .clipShape(Circle())
            }

            Text(conversation.preview)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(conversation.lastMessageTime.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
