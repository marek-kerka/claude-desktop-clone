//
//  ConversationStorageTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

@MainActor
final class ConversationStorageTests: XCTestCase {

    var storage: ConversationStorage!
    var testFileURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Use temporary directory for testing
        let tempDir = FileManager.default.temporaryDirectory
        testFileURL = tempDir.appendingPathComponent("test_conversations_\(UUID().uuidString).json")

        storage = ConversationStorage(storageURL: testFileURL)
    }

    override func tearDown() async throws {
        // Clean up test file
        if FileManager.default.fileExists(atPath: testFileURL.path) {
            try? FileManager.default.removeItem(at: testFileURL)
        }
        storage = nil
        try await super.tearDown()
    }

    func testInitialState() {
        XCTAssertNotNil(storage.conversations)
    }

    func testCreateConversation() {
        let conversation = storage.createConversation()

        XCTAssertEqual(storage.conversations.count, 1)
        XCTAssertEqual(storage.conversations[0].id, conversation.id)
    }

    func testCreateConversationWithModel() {
        let conversation = storage.createConversation(model: .opus)

        XCTAssertEqual(conversation.model, .opus)
        XCTAssertEqual(storage.conversations[0].model, .opus)
    }

    func testUpdateConversation() {
        var conversation = storage.createConversation()
        conversation.title = "Updated Title"

        storage.updateConversation(conversation)

        XCTAssertEqual(storage.conversations[0].title, "Updated Title")
    }

    func testUpdateConversationMovesToTop() {
        let conv1 = storage.createConversation()
        let conv2 = storage.createConversation()

        XCTAssertEqual(storage.conversations[0].id, conv2.id)
        XCTAssertEqual(storage.conversations[1].id, conv1.id)

        var updatedConv1 = conv1
        updatedConv1.title = "Updated"
        storage.updateConversation(updatedConv1)

        XCTAssertEqual(storage.conversations[0].id, conv1.id)
        XCTAssertEqual(storage.conversations[1].id, conv2.id)
    }

    func testDeleteConversation() {
        let conversation = storage.createConversation()

        XCTAssertEqual(storage.conversations.count, 1)

        storage.deleteConversation(conversation)

        XCTAssertEqual(storage.conversations.count, 0)
    }

    func testDeleteAllConversations() {
        _ = storage.createConversation()
        _ = storage.createConversation()
        _ = storage.createConversation()

        XCTAssertEqual(storage.conversations.count, 3)

        storage.deleteAllConversations()

        XCTAssertEqual(storage.conversations.count, 0)
    }

    func testConversationsSortedByMostRecent() {
        let conv1 = storage.createConversation()

        Thread.sleep(forTimeInterval: 0.1)

        let conv2 = storage.createConversation()

        XCTAssertEqual(storage.conversations[0].id, conv2.id)
        XCTAssertEqual(storage.conversations[1].id, conv1.id)
    }
}
