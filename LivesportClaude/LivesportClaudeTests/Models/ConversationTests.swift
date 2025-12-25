//
//  ConversationTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class ConversationTests: XCTestCase {

    func testConversationInitialization() {
        let conversation = Conversation()

        XCTAssertNotNil(conversation.id)
        XCTAssertEqual(conversation.title, "New Conversation")
        XCTAssertTrue(conversation.messages.isEmpty)
        XCTAssertEqual(conversation.model, .sonnet)
    }

    func testConversationWithCustomTitle() {
        let conversation = Conversation(title: "Custom Title")

        XCTAssertEqual(conversation.title, "Custom Title")
    }

    func testConversationWithModel() {
        let conversation = Conversation(model: .opus)

        XCTAssertEqual(conversation.model, .opus)
    }

    func testAddMessage() {
        var conversation = Conversation()
        let message = Message(role: .user, text: "Hello")

        XCTAssertTrue(conversation.messages.isEmpty)

        conversation.addMessage(message)

        XCTAssertEqual(conversation.messages.count, 1)
        XCTAssertEqual(conversation.messages[0].id, message.id)
    }

    func testAddMessageUpdatesTimestamp() {
        var conversation = Conversation()
        let initialTime = conversation.updatedAt

        Thread.sleep(forTimeInterval: 0.1)

        let message = Message(role: .user, text: "Hello")
        conversation.addMessage(message)

        XCTAssertGreaterThan(conversation.updatedAt, initialTime)
    }

    func testAutoGenerateTitle() {
        var conversation = Conversation()
        let message = Message(role: .user, text: "What is the weather today?")

        conversation.addMessage(message)

        XCTAssertNotEqual(conversation.title, "New Conversation")
        XCTAssertTrue(conversation.title.contains("What is the weather"))
    }

    func testAutoGenerateTitleLongMessage() {
        var conversation = Conversation()
        let longText = String(repeating: "a", count: 100)
        let message = Message(role: .user, text: longText)

        conversation.addMessage(message)

        XCTAssertLessThanOrEqual(conversation.title.count, 53) // 50 + "..."
        XCTAssertTrue(conversation.title.hasSuffix("..."))
    }

    func testPreview() {
        var conversation = Conversation()
        let message = Message(role: .user, text: "This is a preview test")

        conversation.addMessage(message)

        XCTAssertEqual(conversation.preview, "This is a preview test")
    }

    func testPreviewLongMessage() {
        var conversation = Conversation()
        let longText = String(repeating: "x", count: 150)
        let message = Message(role: .user, text: longText)

        conversation.addMessage(message)

        XCTAssertLessThanOrEqual(conversation.preview.count, 100)
    }

    func testPreviewEmptyConversation() {
        let conversation = Conversation()

        XCTAssertEqual(conversation.preview, "Empty conversation")
    }

    func testLastMessageTime() {
        var conversation = Conversation()
        let message1 = Message(role: .user, text: "First")

        conversation.addMessage(message1)

        Thread.sleep(forTimeInterval: 0.1)

        let message2 = Message(role: .assistant, text: "Second")
        conversation.addMessage(message2)

        XCTAssertGreaterThan(conversation.lastMessageTime, message1.timestamp)
        XCTAssertEqual(conversation.lastMessageTime, message2.timestamp)
    }

    func testConversationCodable() throws {
        let conversation = Conversation(title: "Test Conversation", model: .opus)

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(conversation)
        let decoded = try decoder.decode(Conversation.self, from: data)

        XCTAssertEqual(decoded.id, conversation.id)
        XCTAssertEqual(decoded.title, conversation.title)
        XCTAssertEqual(decoded.model, conversation.model)
    }

    func testConversationWithMessages() throws {
        var conversation = Conversation()
        conversation.addMessage(Message(role: .user, text: "Hello"))
        conversation.addMessage(Message(role: .assistant, text: "Hi there"))

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(conversation)
        let decoded = try decoder.decode(Conversation.self, from: data)

        XCTAssertEqual(decoded.messages.count, 2)
        XCTAssertEqual(decoded.messages[0].textContent, "Hello")
        XCTAssertEqual(decoded.messages[1].textContent, "Hi there")
    }
}
