//
//  UsageStorageTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

@MainActor
final class UsageStorageTests: XCTestCase {

    var storage: UsageStorage!

    override func setUp() async throws {
        storage = UsageStorage()
        storage.deleteAllRecords()
    }

    override func tearDown() async throws {
        storage.deleteAllRecords()
        storage = nil
    }

    func testInitialState() {
        XCTAssertEqual(storage.records.count, 0)
        XCTAssertEqual(storage.statistics.totalCost, 0)
    }

    func testAddRecord() {
        let record = UsageRecord(
            model: .sonnet,
            inputTokens: 1000,
            outputTokens: 500
        )

        storage.addRecord(record)

        XCTAssertEqual(storage.records.count, 1)
        XCTAssertEqual(storage.records.first?.id, record.id)
    }

    func testAddRecordWithParameters() {
        storage.addRecord(
            model: .opus,
            inputTokens: 2000,
            outputTokens: 1000
        )

        XCTAssertEqual(storage.records.count, 1)
        XCTAssertEqual(storage.records.first?.model, ClaudeModel.opus.rawValue)
        XCTAssertEqual(storage.records.first?.inputTokens, 2000)
        XCTAssertEqual(storage.records.first?.outputTokens, 1000)
    }

    func testDeleteAllRecords() {
        storage.addRecord(model: .sonnet, inputTokens: 1000, outputTokens: 500)
        storage.addRecord(model: .opus, inputTokens: 2000, outputTokens: 1000)

        XCTAssertEqual(storage.records.count, 2)

        storage.deleteAllRecords()

        XCTAssertEqual(storage.records.count, 0)
    }

    func testDeleteRecordsBefore() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!

        storage.addRecord(
            UsageRecord(
                id: UUID(),
                date: twoDaysAgo,
                model: .sonnet,
                inputTokens: 1000,
                outputTokens: 500
            )
        )

        storage.addRecord(
            UsageRecord(
                id: UUID(),
                date: yesterday,
                model: .opus,
                inputTokens: 2000,
                outputTokens: 1000
            )
        )

        storage.addRecord(
            UsageRecord(
                id: UUID(),
                date: now,
                model: .haiku,
                inputTokens: 3000,
                outputTokens: 1500
            )
        )

        XCTAssertEqual(storage.records.count, 3)

        storage.deleteRecordsBefore(date: yesterday)

        XCTAssertEqual(storage.records.count, 2)
    }

    func testStatistics() {
        storage.addRecord(model: .sonnet, inputTokens: 1000, outputTokens: 500)
        storage.addRecord(model: .opus, inputTokens: 2000, outputTokens: 1000)

        let stats = storage.statistics

        XCTAssertEqual(stats.totalInputTokens, 3000)
        XCTAssertEqual(stats.totalOutputTokens, 1500)
        XCTAssertEqual(stats.totalTokens, 4500)
        XCTAssertGreaterThan(stats.totalCost, 0)
    }

    func testPersistence() {
        storage.addRecord(model: .sonnet, inputTokens: 1000, outputTokens: 500)
        storage.addRecord(model: .opus, inputTokens: 2000, outputTokens: 1000)

        let firstCount = storage.records.count
        XCTAssertEqual(firstCount, 2)

        let newStorage = UsageStorage()
        XCTAssertEqual(newStorage.records.count, firstCount)
    }
}
