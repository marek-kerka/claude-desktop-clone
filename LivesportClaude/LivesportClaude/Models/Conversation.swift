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
    var tags: [Tag]

    init(
        id: UUID = UUID(),
        title: String = "New Conversation",
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        model: ClaudeModel = .sonnet,
        tags: [Tag] = []
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.model = model
        self.tags = tags
    }

    // Custom decoding to support backward compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        messages = try container.decode([Message].self, forKey: .messages)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        model = try container.decode(ClaudeModel.self, forKey: .model)

        // Decode tags with default value for backward compatibility
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
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
