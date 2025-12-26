//
//  ConversationListView.swift
//  LivesportClaude
//

import SwiftUI

struct ConversationListView: View {
    @ObservedObject var storage: ConversationStorage
    @Binding var selectedConversation: Conversation?
    @StateObject private var tagStorage = TagStorage.shared
    @State private var showingNewConversationSheet = false
    @State private var selectedModel: ClaudeModel = .sonnet
    @State private var selectedTagFilter: Tag?

    var filteredConversations: [Conversation] {
        if let tagFilter = selectedTagFilter {
            return storage.conversations.filter { conversation in
                conversation.tags.contains(where: { $0.id == tagFilter.id })
            }
        }
        return storage.conversations
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Conversations")
                    .font(.headline)
                Spacer()
                Menu {
                    Button("Haiku 4.5") {
                        createNewConversation(model: .haiku)
                    }
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

            // Tag filter
            if !tagStorage.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // All filter
                        Button(action: { selectedTagFilter = nil }) {
                            Text("All")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTagFilter == nil ? Color.accentColor : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTagFilter == nil ? .white : .primary)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        ForEach(tagStorage.tags) { tag in
                            Button(action: { selectedTagFilter = tag }) {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(tag.color.color)
                                        .frame(width: 8, height: 8)

                                    Text(tag.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    selectedTagFilter?.id == tag.id ?
                                    tag.color.color.opacity(0.3) :
                                    Color.gray.opacity(0.2)
                                )
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }

            Divider()

            // Conversations list
            if filteredConversations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: selectedTagFilter != nil ? "tag.slash" : "bubble.left.and.bubble.right")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(selectedTagFilter != nil ? "No conversations with this tag" : "No conversations yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(selectedTagFilter != nil ? "Try a different tag filter" : "Click + to start a new chat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedConversation) {
                    ForEach(filteredConversations) { conversation in
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

    var modelBadge: (text: String, color: Color) {
        switch conversation.model {
        case .haiku:
            return ("H", .green)
        case .sonnet:
            return ("S", .blue)
        case .opus:
            return ("O", .purple)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(conversation.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                Spacer()

                // Model badge
                Text(modelBadge.text)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 14, height: 14)
                    .background(modelBadge.color)
                    .clipShape(Circle())
            }

            Text(conversation.preview)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Tags
            if !conversation.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(conversation.tags.prefix(3)) { tag in
                            HStack(spacing: 2) {
                                Circle()
                                    .fill(tag.color.color)
                                    .frame(width: 6, height: 6)
                                Text(tag.name)
                                    .font(.system(size: 9))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tag.color.color.opacity(0.15))
                            .cornerRadius(8)
                        }
                        if conversation.tags.count > 3 {
                            Text("+\(conversation.tags.count - 3)")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Text(conversation.lastMessageTime.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
