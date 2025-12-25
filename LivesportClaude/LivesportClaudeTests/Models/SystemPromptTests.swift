//
//  SystemPromptTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class SystemPromptTests: XCTestCase {

    func testSystemPromptInitialization() {
        let prompt = SystemPrompt(name: "Test Prompt", prompt: "Test content")

        XCTAssertNotNil(prompt.id)
        XCTAssertEqual(prompt.name, "Test Prompt")
        XCTAssertEqual(prompt.prompt, "Test content")
        XCTAssertFalse(prompt.isDefault)
    }

    func testSystemPromptWithDefault() {
        let prompt = SystemPrompt(
            name: "Default",
            prompt: "Content",
            isDefault: true
        )

        XCTAssertTrue(prompt.isDefault)
    }

    func testBuiltInPromptsCount() {
        XCTAssertEqual(SystemPrompt.builtInPrompts.count, 6)
    }

    func testBuiltInPromptsNames() {
        let names = SystemPrompt.builtInPrompts.map { $0.name }

        XCTAssertTrue(names.contains("Default Assistant"))
        XCTAssertTrue(names.contains("Code Expert"))
        XCTAssertTrue(names.contains("Data Analyst"))
        XCTAssertTrue(names.contains("Product Manager"))
        XCTAssertTrue(names.contains("Technical Writer"))
        XCTAssertTrue(names.contains("DevOps Engineer"))
    }

    func testDefaultAssistantPrompt() {
        let defaultPrompt = SystemPrompt.builtInPrompts.first { $0.name == "Default Assistant" }

        XCTAssertNotNil(defaultPrompt)
        XCTAssertTrue(defaultPrompt!.isDefault)
        XCTAssertFalse(defaultPrompt!.prompt.isEmpty)
    }

    func testCodeExpertPrompt() {
        let codeExpert = SystemPrompt.builtInPrompts.first { $0.name == "Code Expert" }

        XCTAssertNotNil(codeExpert)
        XCTAssertTrue(codeExpert!.prompt.contains("software engineer"))
        XCTAssertTrue(codeExpert!.prompt.contains("React"))
    }

    func testDataAnalystPrompt() {
        let dataAnalyst = SystemPrompt.builtInPrompts.first { $0.name == "Data Analyst" }

        XCTAssertNotNil(dataAnalyst)
        XCTAssertTrue(dataAnalyst!.prompt.contains("data analysis"))
        XCTAssertTrue(dataAnalyst!.prompt.contains("sports data"))
    }

    func testSystemPromptCodable() throws {
        let prompt = SystemPrompt(name: "Test", prompt: "Content")

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(prompt)
        let decoded = try decoder.decode(SystemPrompt.self, from: data)

        XCTAssertEqual(decoded.id, prompt.id)
        XCTAssertEqual(decoded.name, prompt.name)
        XCTAssertEqual(decoded.prompt, prompt.prompt)
        XCTAssertEqual(decoded.isDefault, prompt.isDefault)
    }

    func testSystemPromptIdentifiable() {
        let prompt1 = SystemPrompt(name: "Prompt 1", prompt: "Content 1")
        let prompt2 = SystemPrompt(name: "Prompt 2", prompt: "Content 2")

        XCTAssertNotEqual(prompt1.id, prompt2.id)
    }

    func testAllBuiltInPromptsHaveContent() {
        for prompt in SystemPrompt.builtInPrompts {
            XCTAssertFalse(prompt.name.isEmpty, "Prompt should have a name")
            XCTAssertFalse(prompt.prompt.isEmpty, "Prompt should have content")
        }
    }

    func testOnlyOneDefaultPrompt() {
        let defaultPrompts = SystemPrompt.builtInPrompts.filter { $0.isDefault }
        XCTAssertEqual(defaultPrompts.count, 1, "Should have exactly one default prompt")
    }
}
