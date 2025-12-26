//
//  UsageRecordTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class UsageRecordTests: XCTestCase {

    func testUsageRecordInitialization() {
        let record = UsageRecord(
            model: .sonnet,
            inputTokens: 1000,
            outputTokens: 500
        )

        XCTAssertNotNil(record.id)
        XCTAssertEqual(record.model, ClaudeModel.sonnet.rawValue)
        XCTAssertEqual(record.inputTokens, 1000)
        XCTAssertEqual(record.outputTokens, 500)
        XCTAssertGreaterThan(record.cost, 0)
    }

    func testUsageRecordCostCalculation() {
        let record = UsageRecord(
            model: .sonnet,
            inputTokens: 100_000,
            outputTokens: 50_000
        )

        let expectedCost = ModelPricing.getCost(
            model: .sonnet,
            inputTokens: 100_000,
            outputTokens: 50_000
        )
        XCTAssertEqual(record.cost, expectedCost, accuracy: 0.0001)
    }

    func testUsageRecordTotalTokens() {
        let record = UsageRecord(
            model: .haiku,
            inputTokens: 1000,
            outputTokens: 2000
        )

        XCTAssertEqual(record.totalTokens, 3000)
    }

    func testUsageStatisticsEmpty() {
        let stats = UsageStatistics.empty

        XCTAssertEqual(stats.totalCost, 0)
        XCTAssertEqual(stats.totalInputTokens, 0)
        XCTAssertEqual(stats.totalOutputTokens, 0)
        XCTAssertEqual(stats.totalTokens, 0)
    }

    func testUsageStatisticsTotals() {
        let records = [
            UsageRecord(model: .sonnet, inputTokens: 1000, outputTokens: 500),
            UsageRecord(model: .opus, inputTokens: 2000, outputTokens: 1000),
            UsageRecord(model: .haiku, inputTokens: 3000, outputTokens: 1500)
        ]

        let stats = UsageStatistics(records: records)

        XCTAssertEqual(stats.totalInputTokens, 6000)
        XCTAssertEqual(stats.totalOutputTokens, 3000)
        XCTAssertEqual(stats.totalTokens, 9000)
        XCTAssertGreaterThan(stats.totalCost, 0)
    }

    func testUsageStatisticsFilterByModel() {
        let records = [
            UsageRecord(model: .sonnet, inputTokens: 1000, outputTokens: 500),
            UsageRecord(model: .opus, inputTokens: 2000, outputTokens: 1000),
            UsageRecord(model: .sonnet, inputTokens: 3000, outputTokens: 1500)
        ]

        let stats = UsageStatistics(records: records)
        let sonnetStats = stats.filterByModel(.sonnet)

        XCTAssertEqual(sonnetStats.records.count, 2)
        XCTAssertEqual(sonnetStats.totalInputTokens, 4000)
        XCTAssertEqual(sonnetStats.totalOutputTokens, 2000)
    }

    func testUsageStatisticsFilterByDateRange() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!

        let records = [
            UsageRecord(
                id: UUID(),
                date: now,
                model: .sonnet,
                inputTokens: 1000,
                outputTokens: 500
            ),
            UsageRecord(
                id: UUID(),
                date: yesterday,
                model: .opus,
                inputTokens: 2000,
                outputTokens: 1000
            ),
            UsageRecord(
                id: UUID(),
                date: twoDaysAgo,
                model: .haiku,
                inputTokens: 3000,
                outputTokens: 1500
            )
        ]

        let stats = UsageStatistics(records: records)
        let filtered = stats.filterByDateRange(from: yesterday, to: now)

        XCTAssertEqual(filtered.records.count, 2)
    }

    func testUsageRecordCodable() throws {
        let original = UsageRecord(
            model: .sonnet,
            inputTokens: 1000,
            outputTokens: 500
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(UsageRecord.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.model, original.model)
        XCTAssertEqual(decoded.inputTokens, original.inputTokens)
        XCTAssertEqual(decoded.outputTokens, original.outputTokens)
        XCTAssertEqual(decoded.cost, original.cost, accuracy: 0.0001)
    }

    func testUsageRecordEquality() {
        let id = UUID()
        let date = Date()

        let record1 = UsageRecord(
            id: id,
            date: date,
            model: .sonnet,
            inputTokens: 1000,
            outputTokens: 500
        )

        let record2 = UsageRecord(
            id: id,
            date: date,
            model: .sonnet,
            inputTokens: 1000,
            outputTokens: 500
        )

        let record3 = UsageRecord(
            id: UUID(),
            date: date,
            model: .sonnet,
            inputTokens: 1000,
            outputTokens: 500
        )

        XCTAssertEqual(record1, record2)
        XCTAssertNotEqual(record1, record3)
    }
}
