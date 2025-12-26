//
//  SystemPromptStorageTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

@MainActor
final class SystemPromptStorageTests: XCTestCase {

    var storage: SystemPromptStorage!
    var testFileURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Use temporary directory for testing
        let tempDir = FileManager.default.temporaryDirectory
        testFileURL = tempDir.appendingPathComponent("test_prompts_\(UUID().uuidString).json")

        storage = SystemPromptStorage(storageURL: testFileURL)
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
        XCTAssertFalse(storage.systemPrompts.isEmpty)
        XCTAssertNotNil(storage.selectedPromptId)
    }

    func testBuiltInPromptsLoaded() {
        XCTAssertGreaterThanOrEqual(storage.systemPrompts.count, 6)
    }

    func testAddPrompt() {
        let initialCount = storage.systemPrompts.count
        let newPrompt = SystemPrompt(name: "Test Prompt", prompt: "Test content")

        storage.addPrompt(newPrompt)

        XCTAssertEqual(storage.systemPrompts.count, initialCount + 1)
        XCTAssertTrue(storage.systemPrompts.contains { $0.id == newPrompt.id })
    }

    func testUpdatePrompt() {
        let prompt = SystemPrompt(name: "Original", prompt: "Original content")
        storage.addPrompt(prompt)

        var updatedPrompt = prompt
        updatedPrompt.name = "Updated"
        updatedPrompt.prompt = "Updated content"

        storage.updatePrompt(updatedPrompt)

        let found = storage.systemPrompts.first { $0.id == prompt.id }
        XCTAssertEqual(found?.name, "Updated")
        XCTAssertEqual(found?.prompt, "Updated content")
    }

    func testDeletePrompt() {
        let prompt = SystemPrompt(name: "To Delete", prompt: "Content")
        storage.addPrompt(prompt)

        let beforeCount = storage.systemPrompts.count
        storage.deletePrompt(prompt)

        XCTAssertEqual(storage.systemPrompts.count, beforeCount - 1)
        XCTAssertFalse(storage.systemPrompts.contains { $0.id == prompt.id })
    }

    func testDeletePromptUpdatesSelection() {
        let prompt = SystemPrompt(name: "Selected", prompt: "Content")
        storage.addPrompt(prompt)
        storage.selectPrompt(prompt)

        XCTAssertEqual(storage.selectedPromptId, prompt.id)

        storage.deletePrompt(prompt)

        XCTAssertNotEqual(storage.selectedPromptId, prompt.id)
        XCTAssertNotNil(storage.selectedPromptId)
    }

    func testGetSelectedPrompt() {
        let prompt = storage.getSelectedPrompt()

        XCTAssertNotNil(prompt)
        XCTAssertEqual(prompt?.id, storage.selectedPromptId)
    }

    func testSelectPrompt() {
        let prompt = SystemPrompt(name: "New Selection", prompt: "Content")
        storage.addPrompt(prompt)

        storage.selectPrompt(prompt)

        XCTAssertEqual(storage.selectedPromptId, prompt.id)
    }

    func testGetSelectedPromptReturnsFirstIfNoneSelected() {
        storage.selectedPromptId = nil

        let prompt = storage.getSelectedPrompt()

        XCTAssertNotNil(prompt)
        XCTAssertEqual(prompt?.id, storage.systemPrompts.first?.id)
    }
}
