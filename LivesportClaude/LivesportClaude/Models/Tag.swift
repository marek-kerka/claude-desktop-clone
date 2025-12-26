//
//  Tag.swift
//  LivesportClaude
//

import Foundation
import SwiftUI

struct Tag: Codable, Identifiable, Hashable, Equatable {
    let id: UUID
    var name: String
    var color: TagColor

    init(id: UUID = UUID(), name: String, color: TagColor = .blue) {
        self.id = id
        self.name = name
        self.color = color
    }

    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum TagColor: String, Codable, CaseIterable {
    case blue
    case green
    case orange
    case red
    case purple
    case pink
    case yellow
    case gray

    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .green:
            return .green
        case .orange:
            return .orange
        case .red:
            return .red
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .yellow:
            return .yellow
        case .gray:
            return .gray
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}
