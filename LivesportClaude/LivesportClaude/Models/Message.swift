//
//  Message.swift
//  LivesportClaude
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let role: Role
    let content: [ContentBlock]
    let timestamp: Date

    enum Role: String, Codable {
        case user
        case assistant
    }

    enum ContentBlock: Codable, Equatable {
        case text(String)
        case image(ImageContent)

        struct ImageContent: Codable, Equatable {
            let data: Data
            let mediaType: String
        }
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

        struct APIContent: Codable {
            let type: String
            let text: String?
            let source: ImageSource?

            struct ImageSource: Codable {
                let type: String
                let media_type: String
                let data: String
            }
        }
    }

    func toAPIMessage() -> APIMessage {
        let apiContent = content.map { block -> APIMessage.APIContent in
            switch block {
            case .text(let text):
                return APIMessage.APIContent(type: "text", text: text, source: nil)
            case .image(let imageContent):
                let base64Data = imageContent.data.base64EncodedString()
                let source = APIMessage.APIContent.ImageSource(
                    type: "base64",
                    media_type: imageContent.mediaType,
                    data: base64Data
                )
                return APIMessage.APIContent(type: "image", text: nil, source: source)
            }
        }
        return APIMessage(role: role.rawValue, content: apiContent)
    }
}
