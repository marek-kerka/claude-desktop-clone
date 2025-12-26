//
//  UsageRecord.swift
//  LivesportClaude
//

import Foundation

struct UsageRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let model: String
    let inputTokens: Int
    let outputTokens: Int
    let cost: Double

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        model: ClaudeModel,
        inputTokens: Int,
        outputTokens: Int
    ) {
        self.id = id
        self.date = date
        self.model = model.rawValue
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cost = ModelPricing.getCost(
            model: model,
            inputTokens: inputTokens,
            outputTokens: outputTokens
        )
    }

    var totalTokens: Int {
        inputTokens + outputTokens
    }
}

struct UsageStatistics {
    let records: [UsageRecord]

    var totalCost: Double {
        records.reduce(0) { $0 + $1.cost }
    }

    var totalInputTokens: Int {
        records.reduce(0) { $0 + $1.inputTokens }
    }

    var totalOutputTokens: Int {
        records.reduce(0) { $0 + $1.outputTokens }
    }

    var totalTokens: Int {
        totalInputTokens + totalOutputTokens
    }

    func filterByDateRange(from startDate: Date, to endDate: Date) -> UsageStatistics {
        let filtered = records.filter { record in
            record.date >= startDate && record.date <= endDate
        }
        return UsageStatistics(records: filtered)
    }

    func filterByModel(_ model: ClaudeModel) -> UsageStatistics {
        let filtered = records.filter { $0.model == model.rawValue }
        return UsageStatistics(records: filtered)
    }

    static var empty: UsageStatistics {
        UsageStatistics(records: [])
    }

    var today: UsageStatistics {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return filterByDateRange(from: startOfDay, to: endOfDay)
    }

    var thisWeek: UsageStatistics {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        ) else {
            return .empty
        }
        return filterByDateRange(from: startOfWeek, to: now)
    }

    var thisMonth: UsageStatistics {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) else {
            return .empty
        }
        return filterByDateRange(from: startOfMonth, to: now)
    }
}
