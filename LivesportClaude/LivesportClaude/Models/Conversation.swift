//
//  Conversation.swift
//  LivesportClaude
//

import Foundation

struct Conversation: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var messages: [Message]
    let createdAt: Date
    var updatedAt: Date
    var model: ClaudeModel

    init(
        id: UUID = UUID(),
        title: String = "New Conversation",
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        model: ClaudeModel = .sonnet
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.model = model
    }

    var preview: String {
        if let firstUserMessage = messages.first(where: { $0.role == .user }) {
            let preview = firstUserMessage.textContent.prefix(100)
            return String(preview)
        }
        return "Empty conversation"
    }

    var lastMessageTime: Date {
        messages.last?.timestamp ?? updatedAt
    }

    mutating func addMessage(_ message: Message) {
        messages.append(message)
        updatedAt = Date()

        // Auto-generate title from first message if still default
        if title == "New Conversation" && message.role == .user {
            title = generateTitle(from: message.textContent)
        }
    }

    private func generateTitle(from text: String) -> String {
        let maxLength = 50
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.count <= maxLength {
            return cleaned
        }
        return String(cleaned.prefix(maxLength)) + "..."
    }
}
