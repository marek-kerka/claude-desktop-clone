//
//  ClaudeModelTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class ClaudeModelTests: XCTestCase {

    func testClaudeModelRawValues() {
        XCTAssertEqual(ClaudeModel.haiku.rawValue, "claude-haiku-4-5-20250815")
        XCTAssertEqual(ClaudeModel.sonnet.rawValue, "claude-sonnet-4-5-20250929")
        XCTAssertEqual(ClaudeModel.opus.rawValue, "claude-opus-4-5-20251101")
    }

    func testClaudeModelDisplayNames() {
        XCTAssertEqual(ClaudeModel.haiku.displayName, "Claude Haiku 4.5")
        XCTAssertEqual(ClaudeModel.sonnet.displayName, "Claude Sonnet 4.5")
        XCTAssertEqual(ClaudeModel.opus.displayName, "Claude Opus 4.5")
    }

    func testClaudeModelDescriptions() {
        XCTAssertFalse(ClaudeModel.haiku.description.isEmpty)
        XCTAssertFalse(ClaudeModel.sonnet.description.isEmpty)
        XCTAssertFalse(ClaudeModel.opus.description.isEmpty)
        XCTAssertTrue(ClaudeModel.haiku.description.contains("Fast"))
        XCTAssertTrue(ClaudeModel.sonnet.description.contains("Fast"))
        XCTAssertTrue(ClaudeModel.opus.description.contains("capable"))
    }

    func testClaudeModelMaxTokens() {
        XCTAssertEqual(ClaudeModel.haiku.maxTokens, 8192)
        XCTAssertEqual(ClaudeModel.sonnet.maxTokens, 8192)
        XCTAssertEqual(ClaudeModel.opus.maxTokens, 8192)
    }

    func testClaudeModelAllCases() {
        XCTAssertEqual(ClaudeModel.allCases.count, 3)
        XCTAssertTrue(ClaudeModel.allCases.contains(.haiku))
        XCTAssertTrue(ClaudeModel.allCases.contains(.sonnet))
        XCTAssertTrue(ClaudeModel.allCases.contains(.opus))
    }

    func testClaudeModelIdentifiable() {
        XCTAssertEqual(ClaudeModel.haiku.id, ClaudeModel.haiku.rawValue)
        XCTAssertEqual(ClaudeModel.sonnet.id, ClaudeModel.sonnet.rawValue)
        XCTAssertEqual(ClaudeModel.opus.id, ClaudeModel.opus.rawValue)
    }

    func testClaudeModelCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let haikuData = try encoder.encode(ClaudeModel.haiku)
        let decodedHaiku = try decoder.decode(ClaudeModel.self, from: haikuData)
        XCTAssertEqual(decodedHaiku, .haiku)

        let sonnetData = try encoder.encode(ClaudeModel.sonnet)
        let decodedSonnet = try decoder.decode(ClaudeModel.self, from: sonnetData)
        XCTAssertEqual(decodedSonnet, .sonnet)

        let opusData = try encoder.encode(ClaudeModel.opus)
        let decodedOpus = try decoder.decode(ClaudeModel.self, from: opusData)
        XCTAssertEqual(decodedOpus, .opus)
    }
}
