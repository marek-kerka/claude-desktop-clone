//
//  ExportServiceTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

@MainActor
final class ExportServiceTests: XCTestCase {

    var testConversation: Conversation!

    override func setUp() async throws {
        try await super.setUp()

        var conversation = Conversation(title: "Test Conversation", model: .sonnet)
        conversation.addMessage(Message(role: .user, text: "Hello, how are you?"))
        conversation.addMessage(Message(role: .assistant, text: "I'm doing well, thank you!"))
        conversation.addMessage(Message(role: .user, text: "Can you help me with Swift?"))
        conversation.addMessage(Message(role: .assistant, text: "Of course! I'd be happy to help with Swift."))

        testConversation = conversation
    }

    override func tearDown() async throws {
        testConversation = nil
        try await super.tearDown()
    }

    func testExportToMarkdown() {
        let markdown = ExportService.exportToMarkdown(conversation: testConversation)

        XCTAssertFalse(markdown.isEmpty)
        XCTAssertTrue(markdown.contains("Test Conversation"))
        XCTAssertTrue(markdown.contains("Claude Sonnet 4.5"))
        XCTAssertTrue(markdown.contains("Hello, how are you?"))
        XCTAssertTrue(markdown.contains("I'm doing well, thank you!"))
    }

    func testMarkdownContainsUserMessages() {
        let markdown = ExportService.exportToMarkdown(conversation: testConversation)

        XCTAssertTrue(markdown.contains("👤 User"))
        XCTAssertTrue(markdown.contains("Hello, how are you?"))
        XCTAssertTrue(markdown.contains("Can you help me with Swift?"))
    }

    func testMarkdownContainsAssistantMessages() {
        let markdown = ExportService.exportToMarkdown(conversation: testConversation)

        XCTAssertTrue(markdown.contains("🤖 Claude"))
        XCTAssertTrue(markdown.contains("I'm doing well, thank you!"))
        XCTAssertTrue(markdown.contains("Of course! I'd be happy to help with Swift."))
    }

    func testMarkdownContainsMetadata() {
        let markdown = ExportService.exportToMarkdown(conversation: testConversation)

        XCTAssertTrue(markdown.contains("**Model:**"))
        XCTAssertTrue(markdown.contains("**Created:**"))
        XCTAssertTrue(markdown.contains("**Messages:**"))
        XCTAssertTrue(markdown.contains("Livesport Claude"))
    }

    func testMarkdownWithImageAttachment() {
        var conv = Conversation(title: "Image Test")
        let imageData = Data([0xFF, 0xD8, 0xFF])
        conv.addMessage(Message(role: .user, content: [
            .text("Check this image"),
            .image(Message.ImageContent(data: imageData, mediaType: "image/jpeg"))
        ]))

        let markdown = ExportService.exportToMarkdown(conversation: conv)

        XCTAssertTrue(markdown.contains("Check this image"))
        XCTAssertTrue(markdown.contains("[Image attachment]"))
    }

    func testSanitizeFilename() {
        var conv = Conversation(title: "Invalid/File:Name?Test")
        conv.addMessage(Message(role: .user, text: "Test"))

        // This should not crash when exporting
        let markdown = ExportService.exportToMarkdown(conversation: conv)
        XCTAssertFalse(markdown.isEmpty)
    }

    func testExportEmptyConversation() {
        let emptyConv = Conversation(title: "Empty")

        let markdown = ExportService.exportToMarkdown(conversation: emptyConv)

        XCTAssertFalse(markdown.isEmpty)
        XCTAssertTrue(markdown.contains("Empty"))
        XCTAssertTrue(markdown.contains("**Messages:** 0"))
    }

    func testMarkdownFormattingSeparators() {
        let markdown = ExportService.exportToMarkdown(conversation: testConversation)

        // Check for markdown separators
        XCTAssertTrue(markdown.contains("---"))
        XCTAssertTrue(markdown.contains("##"))
    }
}
