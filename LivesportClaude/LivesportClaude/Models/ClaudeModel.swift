//
//  ClaudeModel.swift
//  LivesportClaude
//

import Foundation

enum ClaudeModel: String, Codable, CaseIterable, Identifiable {
    case haiku = "claude-haiku-4-5-20250815"
    case sonnet = "claude-sonnet-4-5-20250929"
    case opus = "claude-opus-4-5-20251101"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .haiku:
            return "Claude Haiku 4.5"
        case .sonnet:
            return "Claude Sonnet 4.5"
        case .opus:
            return "Claude Opus 4.5"
        }
    }

    var description: String {
        switch self {
        case .haiku:
            return "Fast and cost-effective - great for quick tasks"
        case .sonnet:
            return "Fast and intelligent - ideal for most tasks"
        case .opus:
            return "Most capable model - best for complex reasoning"
        }
    }

    var maxTokens: Int {
        return 8192
    }
}
