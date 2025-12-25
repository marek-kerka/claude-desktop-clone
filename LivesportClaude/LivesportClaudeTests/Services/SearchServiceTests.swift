//
//  SearchServiceTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

@MainActor
final class SearchServiceTests: XCTestCase {

    var searchService: SearchService!
    var testConversations: [Conversation]!

    override func setUp() async throws {
        try await super.setUp()
        searchService = SearchService()

        // Create test conversations
        var conv1 = Conversation(title: "Swift Programming")
        conv1.addMessage(Message(role: .user, text: "How do I use Swift arrays?"))
        conv1.addMessage(Message(role: .assistant, text: "Swift arrays are versatile data structures."))

        var conv2 = Conversation(title: "Python Basics")
        conv2.addMessage(Message(role: .user, text: "What is a Python dictionary?"))
        conv2.addMessage(Message(role: .assistant, text: "Python dictionaries are key-value pairs."))

        var conv3 = Conversation(title: "Database Design")
        conv3.addMessage(Message(role: .user, text: "How to design a SQL database?"))
        conv3.addMessage(Message(role: .assistant, text: "Start with entity relationship diagrams."))

        testConversations = [conv1, conv2, conv3]
    }

    override func tearDown() async throws {
        searchService = nil
        testConversations = nil
        try await super.tearDown()
    }

    func testInitialState() {
        XCTAssertTrue(searchService.searchQuery.isEmpty)
        XCTAssertTrue(searchService.searchResults.isEmpty)
        XCTAssertFalse(searchService.isSearching)
    }

    func testSearchByConversationTitle() {
        searchService.search(in: testConversations, query: "Swift")

        XCTAssertFalse(searchService.searchResults.isEmpty)
        XCTAssertTrue(searchService.searchResults.contains { $0.conversation.title == "Swift Programming" })
    }

    func testSearchByMessageContent() {
        searchService.search(in: testConversations, query: "dictionary")

        XCTAssertFalse(searchService.searchResults.isEmpty)
        XCTAssertTrue(searchService.searchResults.contains { $0.conversation.title == "Python Basics" })
    }

    func testSearchCaseInsensitive() {
        searchService.search(in: testConversations, query: "SWIFT")

        XCTAssertFalse(searchService.searchResults.isEmpty)

        searchService.search(in: testConversations, query: "swift")

        XCTAssertFalse(searchService.searchResults.isEmpty)
    }

    func testSearchNoResults() {
        searchService.search(in: testConversations, query: "NonexistentTerm12345")

        XCTAssertTrue(searchService.searchResults.isEmpty)
    }

    func testSearchEmptyQuery() {
        searchService.search(in: testConversations, query: "")

        XCTAssertTrue(searchService.searchResults.isEmpty)
    }

    func testSearchWhitespaceQuery() {
        searchService.search(in: testConversations, query: "   ")

        XCTAssertTrue(searchService.searchResults.isEmpty)
    }

    func testSearchMultipleMatches() {
        searchService.search(in: testConversations, query: "how")

        // Should find all conversations that have "how" in them
        XCTAssertGreaterThanOrEqual(searchService.searchResults.count, 2)
    }

    func testClearSearch() {
        searchService.search(in: testConversations, query: "Swift")
        XCTAssertFalse(searchService.searchResults.isEmpty)

        searchService.clearSearch()

        XCTAssertTrue(searchService.searchQuery.isEmpty)
        XCTAssertTrue(searchService.searchResults.isEmpty)
    }

    func testSearchResultContainsContext() {
        searchService.search(in: testConversations, query: "arrays")

        guard let result = searchService.searchResults.first else {
            XCTFail("No search results found")
            return
        }

        XCTAssertFalse(result.context.isEmpty)
        XCTAssertTrue(result.context.lowercased().contains("arrays"))
    }

    func testSearchResultMatchedText() {
        searchService.search(in: testConversations, query: "Python")

        guard let result = searchService.searchResults.first else {
            XCTFail("No search results found")
            return
        }

        XCTAssertFalse(result.matchedText.isEmpty)
    }
}
