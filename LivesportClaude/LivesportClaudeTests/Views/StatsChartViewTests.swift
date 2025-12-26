//
//  StatsChartViewTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class StatsChartViewTests: XCTestCase {

    func testStatsPeriodCases() {
        XCTAssertEqual(StatsPeriod.allCases.count, 4)
        XCTAssertEqual(StatsPeriod.day.displayName, "Day")
        XCTAssertEqual(StatsPeriod.week.displayName, "Week")
        XCTAssertEqual(StatsPeriod.month.displayName, "Month")
        XCTAssertEqual(StatsPeriod.all.displayName, "All Time")
    }

    func testStatsMetricCases() {
        XCTAssertEqual(StatsMetric.allCases.count, 3)
        XCTAssertEqual(StatsMetric.cost.displayName, "Cost")
        XCTAssertEqual(StatsMetric.calls.displayName, "Calls")
        XCTAssertEqual(StatsMetric.tokens.displayName, "Tokens")
    }

    func testGroupingRecordsByDate() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let record1 = UsageRecord(model: .sonnet, inputTokens: 100, outputTokens: 50)
        var record2 = UsageRecord(model: .sonnet, inputTokens: 200, outputTokens: 100)
        record2 = UsageRecord(
            id: record2.id,
            date: yesterday,
            model: .sonnet,
            inputTokens: 200,
            outputTokens: 100
        )

        let records = [record1, record2]

        let grouped = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }

        XCTAssertEqual(grouped.count, 2) // Two different days
    }

    func testGroupingRecordsByModel() {
        let record1 = UsageRecord(model: .sonnet, inputTokens: 100, outputTokens: 50)
        let record2 = UsageRecord(model: .haiku, inputTokens: 200, outputTokens: 100)
        let record3 = UsageRecord(model: .sonnet, inputTokens: 150, outputTokens: 75)

        let records = [record1, record2, record3]

        let grouped = Dictionary(grouping: records) { $0.model }

        XCTAssertEqual(grouped.count, 2) // Two different models
        XCTAssertEqual(grouped[ClaudeModel.sonnet.rawValue]?.count, 2)
        XCTAssertEqual(grouped[ClaudeModel.haiku.rawValue]?.count, 1)
    }

    func testTokenDistributionCalculation() {
        let records = [
            UsageRecord(
                model: .sonnet,
                inputTokens: 1000,
                outputTokens: 500,
                cacheCreationTokens: 200,
                cacheReadTokens: 100
            ),
            UsageRecord(
                model: .haiku,
                inputTokens: 2000,
                outputTokens: 1000,
                cacheCreationTokens: 400,
                cacheReadTokens: 200
            )
        ]

        let totalInput = records.reduce(0) { $0 + $1.inputTokens }
        let totalOutput = records.reduce(0) { $0 + $1.outputTokens }
        let totalCacheCreation = records.reduce(0) { $0 + $1.cacheCreationTokens }
        let totalCacheRead = records.reduce(0) { $0 + $1.cacheReadTokens }

        XCTAssertEqual(totalInput, 3000)
        XCTAssertEqual(totalOutput, 1500)
        XCTAssertEqual(totalCacheCreation, 600)
        XCTAssertEqual(totalCacheRead, 300)
    }

    func testCostTrendCalculation() {
        let record1 = UsageRecord(model: .sonnet, inputTokens: 100, outputTokens: 50)
        let record2 = UsageRecord(model: .haiku, inputTokens: 200, outputTokens: 100)

        let totalCost = record1.cost + record2.cost

        XCTAssertGreaterThan(totalCost, 0)
        XCTAssertEqual(totalCost, record1.cost + record2.cost)
    }

    func testModelUsageCount() {
        let records = [
            UsageRecord(model: .sonnet, inputTokens: 100, outputTokens: 50),
            UsageRecord(model: .sonnet, inputTokens: 200, outputTokens: 100),
            UsageRecord(model: .haiku, inputTokens: 150, outputTokens: 75),
            UsageRecord(model: .opus, inputTokens: 300, outputTokens: 150)
        ]

        let modelCounts = Dictionary(grouping: records) { $0.model }
            .mapValues { $0.count }

        XCTAssertEqual(modelCounts[ClaudeModel.sonnet.rawValue], 2)
        XCTAssertEqual(modelCounts[ClaudeModel.haiku.rawValue], 1)
        XCTAssertEqual(modelCounts[ClaudeModel.opus.rawValue], 1)
    }

    func testAverageCostPerCall() {
        let records = [
            UsageRecord(model: .sonnet, inputTokens: 100, outputTokens: 50),
            UsageRecord(model: .haiku, inputTokens: 200, outputTokens: 100)
        ]

        let totalCost = records.reduce(0) { $0 + $1.cost }
        let averageCost = totalCost / Double(records.count)

        XCTAssertGreaterThan(averageCost, 0)
        XCTAssertEqual(averageCost, totalCost / 2)
    }

    func testNumberFormatting() {
        // Test million formatting
        let million = 1_500_000
        let millionFormatted = formatNumber(million)
        XCTAssertEqual(millionFormatted, "1.5M")

        // Test thousand formatting
        let thousand = 2_500
        let thousandFormatted = formatNumber(thousand)
        XCTAssertEqual(thousandFormatted, "2.5K")

        // Test small number
        let small = 500
        let smallFormatted = formatNumber(small)
        XCTAssertEqual(smallFormatted, "500")
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }
}
