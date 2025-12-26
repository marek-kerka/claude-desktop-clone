//
//  TagStorageTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

@MainActor
final class TagStorageTests: XCTestCase {
    var tempDirectory: URL!
    var storage: TagStorage!

    override func setUp() async throws {
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let storageURL = tempDirectory.appendingPathComponent("tags.json")
        storage = TagStorage(storageURL: storageURL)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        storage = nil
        tempDirectory = nil
    }

    func testInitialLoadCreatesDefaultTags() {
        // On first load, default tags should be created
        XCTAssertGreaterThanOrEqual(storage.tags.count, 3)

        let tagNames = storage.tags.map { $0.name }
        XCTAssertTrue(tagNames.contains("Work"))
        XCTAssertTrue(tagNames.contains("Personal"))
        XCTAssertTrue(tagNames.contains("Important"))
    }

    func testCreateTag() {
        let initialCount = storage.tags.count
        let tag = storage.createTag(name: "Test", color: .purple)

        XCTAssertEqual(storage.tags.count, initialCount + 1)
        XCTAssertEqual(tag.name, "Test")
        XCTAssertEqual(tag.color, .purple)
        XCTAssertTrue(storage.tags.contains(where: { $0.id == tag.id }))
    }

    func testUpdateTag() {
        let tag = storage.createTag(name: "Original", color: .blue)
        var updatedTag = tag
        updatedTag.name = "Updated"
        updatedTag.color = .red

        storage.updateTag(updatedTag)

        let found = storage.tags.first(where: { $0.id == tag.id })
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Updated")
        XCTAssertEqual(found?.color, .red)
    }

    func testDeleteTag() {
        let tag = storage.createTag(name: "ToDelete", color: .orange)
        let countBeforeDelete = storage.tags.count

        storage.deleteTag(tag)

        XCTAssertEqual(storage.tags.count, countBeforeDelete - 1)
        XCTAssertFalse(storage.tags.contains(where: { $0.id == tag.id }))
    }

    func testPersistence() {
        let tag = storage.createTag(name: "Persistent", color: .yellow)

        // Create new storage instance with same URL
        let storageURL = tempDirectory.appendingPathComponent("tags.json")
        let newStorage = TagStorage(storageURL: storageURL)

        XCTAssertTrue(newStorage.tags.contains(where: { $0.id == tag.id && $0.name == "Persistent" }))
    }

    func testSaveAndLoad() {
        storage.createTag(name: "Test1", color: .blue)
        storage.createTag(name: "Test2", color: .green)

        let countBeforeSave = storage.tags.count

        // Reload tags
        storage.loadTags()

        XCTAssertEqual(storage.tags.count, countBeforeSave)
    }
}
