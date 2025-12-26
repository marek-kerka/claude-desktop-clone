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
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let cost: Double

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        model: ClaudeModel,
        inputTokens: Int,
        outputTokens: Int,
        cacheCreationTokens: Int = 0,
        cacheReadTokens: Int = 0
    ) {
        self.id = id
        self.date = date
        self.model = model.rawValue
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheCreationTokens = cacheCreationTokens
        self.cacheReadTokens = cacheReadTokens
        self.cost = ModelPricing.getCost(
            model: model,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: cacheCreationTokens,
            cacheReadTokens: cacheReadTokens
        )
    }

    // Custom decoding to support backward compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        model = try container.decode(String.self, forKey: .model)
        inputTokens = try container.decode(Int.self, forKey: .inputTokens)
        outputTokens = try container.decode(Int.self, forKey: .outputTokens)

        // Decode cache tokens with default values for backward compatibility
        cacheCreationTokens = try container.decodeIfPresent(Int.self, forKey: .cacheCreationTokens) ?? 0
        cacheReadTokens = try container.decodeIfPresent(Int.self, forKey: .cacheReadTokens) ?? 0

        // Try to decode cost, or recalculate if missing
        if let decodedCost = try container.decodeIfPresent(Double.self, forKey: .cost) {
            cost = decodedCost
        } else {
            // Recalculate cost for old records
            guard let claudeModel = ClaudeModel(rawValue: model) else {
                cost = 0.0
                return
            }
            cost = ModelPricing.getCost(
                model: claudeModel,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                cacheCreationTokens: cacheCreationTokens,
                cacheReadTokens: cacheReadTokens
            )
        }
    }

    var totalTokens: Int {
        inputTokens + outputTokens + cacheCreationTokens + cacheReadTokens
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

    var totalCacheCreationTokens: Int {
        records.reduce(0) { $0 + $1.cacheCreationTokens }
    }

    var totalCacheReadTokens: Int {
        records.reduce(0) { $0 + $1.cacheReadTokens }
    }

    var totalTokens: Int {
        totalInputTokens + totalOutputTokens + totalCacheCreationTokens + totalCacheReadTokens
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
