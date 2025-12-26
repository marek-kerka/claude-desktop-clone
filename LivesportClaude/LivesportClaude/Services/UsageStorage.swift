//
//  UsageStorage.swift
//  LivesportClaude
//

import Foundation
import Combine

@MainActor
class UsageStorage: ObservableObject {
    static let shared = UsageStorage()

    @Published private(set) var records: [UsageRecord] = []

    private let storageKey = "usageRecords"
    private let userDefaults = UserDefaults.standard

    init() {
        loadRecords()
    }

    var statistics: UsageStatistics {
        UsageStatistics(records: records)
    }

    func addRecord(_ record: UsageRecord) {
        records.append(record)
        saveRecords()
    }

    func addRecord(
        model: ClaudeModel,
        inputTokens: Int,
        outputTokens: Int,
        cacheCreationTokens: Int = 0,
        cacheReadTokens: Int = 0
    ) {
        let record = UsageRecord(
            model: model,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: cacheCreationTokens,
            cacheReadTokens: cacheReadTokens
        )
        addRecord(record)
    }

    func deleteAllRecords() {
        records.removeAll()
        saveRecords()
    }

    func deleteRecordsBefore(date: Date) {
        records.removeAll { $0.date < date }
        saveRecords()
    }

    private func loadRecords() {
        guard let data = userDefaults.data(forKey: storageKey) else {
            records = []
            return
        }

        do {
            let decoder = JSONDecoder()
            records = try decoder.decode([UsageRecord].self, from: data)
        } catch {
            print("Failed to decode usage records: \(error)")
            records = []
        }
    }

    private func saveRecords() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(records)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode usage records: \(error)")
        }
    }
}
