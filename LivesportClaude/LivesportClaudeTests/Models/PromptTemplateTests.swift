//
//  PromptTemplateTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class PromptTemplateTests: XCTestCase {

    func testPromptTemplateInitialization() {
        let template = PromptTemplate(
            title: "Test Template",
            content: "This is test content",
            category: "Testing"
        )

        XCTAssertFalse(template.id.uuidString.isEmpty)
        XCTAssertEqual(template.title, "Test Template")
        XCTAssertEqual(template.content, "This is test content")
        XCTAssertEqual(template.category, "Testing")
    }

    func testPromptTemplateDefaultCategory() {
        let template = PromptTemplate(
            title: "Test",
            content: "Content"
        )

        XCTAssertEqual(template.category, "General")
    }

    func testPromptTemplatePreview() {
        let shortContent = "Short content"
        let shortTemplate = PromptTemplate(title: "Short", content: shortContent)
        XCTAssertEqual(shortTemplate.preview, shortContent)

        let longContent = String(repeating: "a", count: 150)
        let longTemplate = PromptTemplate(title: "Long", content: longContent)
        XCTAssertTrue(longTemplate.preview.count <= 104) // 100 + "..."
        XCTAssertTrue(longTemplate.preview.hasSuffix("..."))
    }

    func testPromptTemplateCodable() throws {
        let template = PromptTemplate(
            title: "Code Review",
            content: "Please review this code",
            category: "Development"
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(template)
        let decoded = try decoder.decode(PromptTemplate.self, from: data)

        XCTAssertEqual(template.id, decoded.id)
        XCTAssertEqual(template.title, decoded.title)
        XCTAssertEqual(template.content, decoded.content)
        XCTAssertEqual(template.category, decoded.category)
    }

    func testPromptTemplateHashable() {
        let template1 = PromptTemplate(title: "Test1", content: "Content1")
        let template2 = PromptTemplate(title: "Test2", content: "Content2")

        var set = Set<PromptTemplate>()
        set.insert(template1)
        set.insert(template2)

        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(template1))
        XCTAssertTrue(set.contains(template2))
    }
}
