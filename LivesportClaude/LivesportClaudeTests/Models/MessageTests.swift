//
//  MessageTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class MessageTests: XCTestCase {

    func testMessageInitialization() {
        let message = Message(role: .user, text: "Hello")

        XCTAssertNotNil(message.id)
        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.content.count, 1)
    }

    func testMessageWithContent() {
        let content: [Message.ContentBlock] = [
            .text("Hello"),
            .text("World")
        ]
        let message = Message(role: .assistant, content: content)

        XCTAssertEqual(message.content.count, 2)
        XCTAssertEqual(message.role, .assistant)
    }

    func testMessageTextContent() {
        let message = Message(role: .user, content: [
            .text("First line"),
            .text("Second line")
        ])

        let textContent = message.textContent
        XCTAssertTrue(textContent.contains("First line"))
        XCTAssertTrue(textContent.contains("Second line"))
    }

    func testMessageTextContentWithImage() {
        let imageData = Data([0x00, 0x01, 0x02])
        let message = Message(role: .user, content: [
            .text("Text content"),
            .image(Message.ContentBlock.ImageContent(data: imageData, mediaType: "image/png"))
        ])

        let textContent = message.textContent
        XCTAssertEqual(textContent, "Text content")
    }

    func testMessageRoleValues() {
        XCTAssertEqual(Message.Role.user.rawValue, "user")
        XCTAssertEqual(Message.Role.assistant.rawValue, "assistant")
    }

    func testMessageCodable() throws {
        let message = Message(role: .user, text: "Test message")

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(message)
        let decoded = try decoder.decode(Message.self, from: data)

        XCTAssertEqual(decoded.id, message.id)
        XCTAssertEqual(decoded.role, message.role)
        XCTAssertEqual(decoded.textContent, message.textContent)
    }

    func testMessageAPIMessageConversion() {
        let message = Message(role: .user, text: "Hello")
        let apiMessage = message.toAPIMessage()

        XCTAssertEqual(apiMessage.role, "user")
        XCTAssertEqual(apiMessage.content.count, 1)
        XCTAssertEqual(apiMessage.content[0].type, "text")
        XCTAssertEqual(apiMessage.content[0].text, "Hello")
    }

    func testMessageAPIMessageWithImage() {
        let imageData = Data([0xFF, 0xD8, 0xFF]) // JPEG header
        let message = Message(role: .user, content: [
            .text("Check this image"),
            .image(Message.ContentBlock.ImageContent(data: imageData, mediaType: "image/jpeg"))
        ])

        let apiMessage = message.toAPIMessage()

        XCTAssertEqual(apiMessage.content.count, 2)
        XCTAssertEqual(apiMessage.content[0].type, "text")
        XCTAssertEqual(apiMessage.content[1].type, "image")
        XCTAssertNotNil(apiMessage.content[1].source)
        XCTAssertEqual(apiMessage.content[1].source?.mediaType, "image/jpeg")
    }

    func testContentBlockEquality() {
        let text1 = Message.ContentBlock.text("Hello")
        let text2 = Message.ContentBlock.text("Hello")
        let text3 = Message.ContentBlock.text("World")

        XCTAssertEqual(text1, text2)
        XCTAssertNotEqual(text1, text3)
    }

    func testImageContentEquality() {
        let data1 = Data([0x01, 0x02])
        let data2 = Data([0x01, 0x02])
        let data3 = Data([0x03, 0x04])

        let img1 = Message.ContentBlock.ImageContent(data: data1, mediaType: "image/png")
        let img2 = Message.ContentBlock.ImageContent(data: data2, mediaType: "image/png")
        let img3 = Message.ContentBlock.ImageContent(data: data3, mediaType: "image/png")

        XCTAssertEqual(img1, img2)
        XCTAssertNotEqual(img1, img3)
    }
}
