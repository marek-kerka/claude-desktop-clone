//
//  ConversationTagTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class ConversationTagTests: XCTestCase {

    func testConversationWithTags() {
        let tag1 = Tag(name: "Work", color: .blue)
        let tag2 = Tag(name: "Important", color: .red)

        let conversation = Conversation(tags: [tag1, tag2])

        XCTAssertEqual(conversation.tags.count, 2)
        XCTAssertTrue(conversation.tags.contains(where: { $0.id == tag1.id }))
        XCTAssertTrue(conversation.tags.contains(where: { $0.id == tag2.id }))
    }

    func testConversationDefaultEmptyTags() {
        let conversation = Conversation()

        XCTAssertEqual(conversation.tags.count, 0)
    }

    func testConversationTagsCodable() throws {
        let tag = Tag(name: "Test", color: .blue)
        let conversation = Conversation(tags: [tag])

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(conversation)
        let decodedConversation = try decoder.decode(Conversation.self, from: data)

        XCTAssertEqual(decodedConversation.tags.count, 1)
        XCTAssertEqual(decodedConversation.tags.first?.name, "Test")
        XCTAssertEqual(decodedConversation.tags.first?.color, .blue)
    }

    func testConversationBackwardCompatibility() throws {
        // Simulate old JSON without tags field
        let jsonWithoutTags = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "title": "Test",
            "messages": [],
            "createdAt": "2024-01-01T00:00:00Z",
            "updatedAt": "2024-01-01T00:00:00Z",
            "model": "claude-sonnet-4-5-20250929"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = jsonWithoutTags.data(using: .utf8)!
        let conversation = try decoder.decode(Conversation.self, from: data)

        // Should decode successfully with empty tags
        XCTAssertEqual(conversation.tags.count, 0)
        XCTAssertEqual(conversation.title, "Test")
    }

    func testConversationHashableWithTags() {
        let tag = Tag(name: "Work", color: .blue)
        let conversation1 = Conversation(id: UUID(), tags: [tag])
        let conversation2 = Conversation(id: conversation1.id, tags: [tag])

        XCTAssertEqual(conversation1, conversation2)
    }

    func testFilterConversationsByTag() {
        let workTag = Tag(name: "Work", color: .blue)
        let personalTag = Tag(name: "Personal", color: .green)

        let conv1 = Conversation(title: "Work Conv", tags: [workTag])
        let conv2 = Conversation(title: "Personal Conv", tags: [personalTag])
        let conv3 = Conversation(title: "Both", tags: [workTag, personalTag])
        let conv4 = Conversation(title: "No Tags", tags: [])

        let allConversations = [conv1, conv2, conv3, conv4]

        let workConversations = allConversations.filter { conversation in
            conversation.tags.contains(where: { $0.id == workTag.id })
        }

        XCTAssertEqual(workConversations.count, 2)
        XCTAssertTrue(workConversations.contains(where: { $0.id == conv1.id }))
        XCTAssertTrue(workConversations.contains(where: { $0.id == conv3.id }))
    }
}
