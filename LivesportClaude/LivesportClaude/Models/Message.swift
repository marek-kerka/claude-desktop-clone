//
//  Message.swift
//  LivesportClaude
//

import Foundation

struct Message: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let role: Role
    let content: [ContentBlock]
    let timestamp: Date

    enum Role: String, Codable, Hashable {
        case user
        case assistant
    }

    struct ImageContent: Codable, Equatable, Hashable {
        let data: Data
        let mediaType: String
    }

    enum ContentBlock: Codable, Equatable, Hashable {
        case text(String)
        case image(ImageContent)
    }

    init(id: UUID = UUID(), role: Role, content: [ContentBlock], timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }

    // Convenience initializer for text-only messages
    init(id: UUID = UUID(), role: Role, text: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = [.text(text)]
        self.timestamp = timestamp
    }

    var textContent: String {
        content.compactMap { block in
            if case .text(let text) = block {
                return text
            }
            return nil
        }.joined(separator: "\n")
    }
}

// API Request/Response structures
extension Message {
    struct APIMessage: Codable {
        let role: String
        let content: [APIContent]
    }

    struct APIContent: Codable {
        let type: String
        let text: String?
        let source: APIImageSource?
    }

    struct APIImageSource: Codable {
        let type: String
        let mediaType: String
        let data: String

        enum CodingKeys: String, CodingKey {
            case type, data
            case mediaType = "media_type"
        }
    }

    func toAPIMessage() -> APIMessage {
        let apiContent = content.map { block -> APIContent in
            switch block {
            case .text(let text):
                return APIContent(type: "text", text: text, source: nil)
            case .image(let imageContent):
                let base64Data = imageContent.data.base64EncodedString()
                let source = APIImageSource(
                    type: "base64",
                    mediaType: imageContent.mediaType,
                    data: base64Data
                )
                return APIContent(type: "image", text: nil, source: source)
            }
        }
        return APIMessage(role: role.rawValue, content: apiContent)
    }
}
