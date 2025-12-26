//
//  PromptTemplateStorageTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

@MainActor
final class PromptTemplateStorageTests: XCTestCase {
    var tempDirectory: URL!
    var storage: PromptTemplateStorage!

    override func setUp() async throws {
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let storageURL = tempDirectory.appendingPathComponent("prompt_templates.json")
        storage = PromptTemplateStorage(storageURL: storageURL)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        storage = nil
        tempDirectory = nil
    }

    func testInitialLoadCreatesDefaultTemplates() {
        XCTAssertGreaterThan(storage.templates.count, 0)

        let titles = storage.templates.map { $0.title }
        XCTAssertTrue(titles.contains("Code Review"))
        XCTAssertTrue(titles.contains("Explain Code"))
        XCTAssertTrue(titles.contains("Write Unit Tests"))
    }

    func testCreateTemplate() {
        let initialCount = storage.templates.count

        let template = storage.createTemplate(
            title: "Test Template",
            content: "Test content",
            category: "Testing"
        )

        XCTAssertEqual(storage.templates.count, initialCount + 1)
        XCTAssertEqual(template.title, "Test Template")
        XCTAssertEqual(template.content, "Test content")
        XCTAssertEqual(template.category, "Testing")

        // New template should be at the top
        XCTAssertEqual(storage.templates.first?.id, template.id)
    }

    func testUpdateTemplate() {
        let template = storage.createTemplate(
            title: "Original",
            content: "Original content",
            category: "Test"
        )

        var updated = template
        updated.title = "Updated"
        updated.content = "Updated content"

        storage.updateTemplate(updated)

        let found = storage.templates.first(where: { $0.id == template.id })
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.title, "Updated")
        XCTAssertEqual(found?.content, "Updated content")
    }

    func testDeleteTemplate() {
        let template = storage.createTemplate(
            title: "To Delete",
            content: "Content",
            category: "Test"
        )

        let countBefore = storage.templates.count
        storage.deleteTemplate(template)

        XCTAssertEqual(storage.templates.count, countBefore - 1)
        XCTAssertFalse(storage.templates.contains(where: { $0.id == template.id }))
    }

    func testDeleteAllTemplates() {
        storage.deleteAllTemplates()
        XCTAssertEqual(storage.templates.count, 0)
    }

    func testCategories() {
        storage.deleteAllTemplates()

        storage.createTemplate(title: "T1", content: "C1", category: "Dev")
        storage.createTemplate(title: "T2", content: "C2", category: "Writing")
        storage.createTemplate(title: "T3", content: "C3", category: "Dev")

        let categories = storage.categories
        XCTAssertEqual(categories.count, 2)
        XCTAssertTrue(categories.contains("Dev"))
        XCTAssertTrue(categories.contains("Writing"))
    }

    func testTemplatesInCategory() {
        storage.deleteAllTemplates()

        storage.createTemplate(title: "Dev1", content: "C1", category: "Development")
        storage.createTemplate(title: "Dev2", content: "C2", category: "Development")
        storage.createTemplate(title: "Writing1", content: "C3", category: "Writing")

        let devTemplates = storage.templates(in: "Development")
        XCTAssertEqual(devTemplates.count, 2)

        let writingTemplates = storage.templates(in: "Writing")
        XCTAssertEqual(writingTemplates.count, 1)
    }

    func testPersistence() {
        let template = storage.createTemplate(
            title: "Persistent",
            content: "Content",
            category: "Test"
        )

        // Create new storage with same URL
        let storageURL = tempDirectory.appendingPathComponent("prompt_templates.json")
        let newStorage = PromptTemplateStorage(storageURL: storageURL)

        XCTAssertTrue(newStorage.templates.contains(where: { $0.id == template.id }))
    }

    func testUpdateMovesToTop() {
        storage.deleteAllTemplates()

        let template1 = storage.createTemplate(title: "First", content: "C1", category: "Test")
        let template2 = storage.createTemplate(title: "Second", content: "C2", category: "Test")

        // Update first template
        var updated = template1
        updated.content = "Updated content"
        storage.updateTemplate(updated)

        // Should now be at the top
        XCTAssertEqual(storage.templates.first?.id, template1.id)
        XCTAssertEqual(storage.templates[1].id, template2.id)
    }
}
