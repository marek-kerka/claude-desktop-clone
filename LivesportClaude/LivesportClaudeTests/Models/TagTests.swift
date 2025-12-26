//
//  TagTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class TagTests: XCTestCase {

    func testTagInitialization() {
        let tag = Tag(name: "Work", color: .blue)

        XCTAssertFalse(tag.id.uuidString.isEmpty)
        XCTAssertEqual(tag.name, "Work")
        XCTAssertEqual(tag.color, .blue)
    }

    func testTagEquality() {
        let id = UUID()
        let tag1 = Tag(id: id, name: "Work", color: .blue)
        let tag2 = Tag(id: id, name: "Personal", color: .red)

        XCTAssertEqual(tag1, tag2) // Equal by ID
    }

    func testTagHashable() {
        let tag = Tag(name: "Work", color: .blue)
        var set = Set<Tag>()

        set.insert(tag)
        XCTAssertTrue(set.contains(tag))
    }

    func testTagCodable() throws {
        let tag = Tag(name: "Work", color: .blue)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(tag)
        let decodedTag = try decoder.decode(Tag.self, from: data)

        XCTAssertEqual(tag.id, decodedTag.id)
        XCTAssertEqual(tag.name, decodedTag.name)
        XCTAssertEqual(tag.color, decodedTag.color)
    }

    func testTagColorCases() {
        XCTAssertEqual(TagColor.allCases.count, 8)
        XCTAssertTrue(TagColor.allCases.contains(.blue))
        XCTAssertTrue(TagColor.allCases.contains(.green))
        XCTAssertTrue(TagColor.allCases.contains(.orange))
        XCTAssertTrue(TagColor.allCases.contains(.red))
        XCTAssertTrue(TagColor.allCases.contains(.purple))
        XCTAssertTrue(TagColor.allCases.contains(.pink))
        XCTAssertTrue(TagColor.allCases.contains(.yellow))
        XCTAssertTrue(TagColor.allCases.contains(.gray))
    }

    func testTagColorDisplayName() {
        XCTAssertEqual(TagColor.blue.displayName, "Blue")
        XCTAssertEqual(TagColor.green.displayName, "Green")
        XCTAssertEqual(TagColor.red.displayName, "Red")
    }

    func testTagColorRawValue() {
        XCTAssertEqual(TagColor.blue.rawValue, "blue")
        XCTAssertEqual(TagColor.green.rawValue, "green")
    }

    func testTagColorCodable() throws {
        let color = TagColor.blue
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(color)
        let decodedColor = try decoder.decode(TagColor.self, from: data)

        XCTAssertEqual(color, decodedColor)
    }
}
