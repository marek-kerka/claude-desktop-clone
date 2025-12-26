//
//  PromptTemplate.swift
//  LivesportClaude
//

import Foundation

struct PromptTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var category: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: String = "General",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var preview: String {
        if content.count <= 100 {
            return content
        }
        return String(content.prefix(100)) + "..."
    }
}
