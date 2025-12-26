//
//  StatsChartView.swift
//  LivesportClaude
//

import SwiftUI
import Charts

struct StatsChartView: View {
    @ObservedObject var usageStorage: UsageStorage

    @State private var selectedPeriod: StatsPeriod = .week
    @State private var selectedMetric: StatsMetric = .cost

    var filteredRecords: [UsageRecord] {
        let now = Date()
        let calendar = Calendar.current

        switch selectedPeriod {
        case .day:
            let startOfDay = calendar.startOfDay(for: now)
            return usageStorage.records.filter { $0.date >= startOfDay }
        case .week:
            guard let startOfWeek = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            ) else {
                return usageStorage.records
            }
            return usageStorage.records.filter { $0.date >= startOfWeek }
        case .month:
            guard let startOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: now)
            ) else {
                return usageStorage.records
            }
            return usageStorage.records.filter { $0.date >= startOfMonth }
        case .all:
            return usageStorage.records
        }
    }

    var groupedByDate: [(date: Date, records: [UsageRecord])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredRecords) { record in
            calendar.startOfDay(for: record.date)
        }
        return grouped.map { (date: $0.key, records: $0.value) }
            .sorted { $0.date < $1.date }
    }

    var groupedByModel: [(model: String, records: [UsageRecord])] {
        let grouped = Dictionary(grouping: filteredRecords) { $0.model }
        return grouped.map { (model: $0.key, records: $0.value) }
            .sorted { $0.model < $1.model }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Period selector
            Picker("Period", selection: $selectedPeriod) {
                ForEach(StatsPeriod.allCases) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if filteredRecords.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No data for this period")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary cards
                        StatsOverviewCards(records: filteredRecords)

                        // Cost trend chart
                        ChartCard(title: "Cost Trend") {
                            CostTrendChart(data: groupedByDate)
                        }

                        // Model usage chart
                        ChartCard(title: "Usage by Model") {
                            ModelUsageChart(data: groupedByModel)
                        }

                        // Token distribution chart
                        ChartCard(title: "Token Distribution") {
                            TokenDistributionChart(records: filteredRecords)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct StatsOverviewCards: View {
    let records: [UsageRecord]

    var totalCost: Double {
        records.reduce(0) { $0 + $1.cost }
    }

    var totalTokens: Int {
        records.reduce(0) { $0 + $1.totalTokens }
    }

    var totalCalls: Int {
        records.count
    }

    var averageCostPerCall: Double {
        totalCalls > 0 ? totalCost / Double(totalCalls) : 0
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            OverviewCard(
                title: "Total Cost",
                value: String(format: "$%.4f", totalCost),
                icon: "dollarsign.circle.fill",
                color: .green
            )

            OverviewCard(
                title: "API Calls",
                value: "\(totalCalls)",
                icon: "arrow.left.arrow.right.circle.fill",
                color: .blue
            )

            OverviewCard(
                title: "Total Tokens",
                value: formatNumber(totalTokens),
                icon: "cpu.fill",
                color: .orange
            )

            OverviewCard(
                title: "Avg Cost/Call",
                value: String(format: "$%.4f", averageCostPerCall),
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                color: .purple
            )
        }
    }

    func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }
}

struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
                .frame(height: 250)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct CostTrendChart: View {
    let data: [(date: Date, records: [UsageRecord])]

    var chartData: [(date: Date, cost: Double)] {
        data.map { (date: $0.date, cost: $0.records.reduce(0) { $0 + $1.cost }) }
    }

    var body: some View {
        Chart(chartData, id: \.date) { item in
            LineMark(
                x: .value("Date", item.date, unit: .day),
                y: .value("Cost", item.cost)
            )
            .foregroundStyle(.green)

            AreaMark(
                x: .value("Date", item.date, unit: .day),
                y: .value("Cost", item.cost)
            )
            .foregroundStyle(.green.opacity(0.1))
        }
    }
}

struct ModelUsageChart: View {
    let data: [(model: String, records: [UsageRecord])]

    var chartData: [(model: String, calls: Int)] {
        data.map { (model: modelDisplayName($0.model), calls: $0.records.count) }
    }

    var body: some View {
        Chart(chartData, id: \.model) { item in
            BarMark(
                x: .value("Calls", item.calls),
                y: .value("Model", item.model)
            )
            .foregroundStyle(by: .value("Model", item.model))
        }
        .chartLegend(.hidden)
    }

    private func modelDisplayName(_ rawValue: String) -> String {
        if let model = ClaudeModel(rawValue: rawValue) {
            return model.displayName
        }
        return rawValue
    }
}

struct TokenDistributionChart: View {
    let records: [UsageRecord]

    var totalInputTokens: Int {
        records.reduce(0) { $0 + $1.inputTokens }
    }

    var totalOutputTokens: Int {
        records.reduce(0) { $0 + $1.outputTokens }
    }

    var totalCacheCreation: Int {
        records.reduce(0) { $0 + $1.cacheCreationTokens }
    }

    var totalCacheRead: Int {
        records.reduce(0) { $0 + $1.cacheReadTokens }
    }

    var chartData: [(type: String, count: Int)] {
        var data: [(type: String, count: Int)] = []

        if totalInputTokens > 0 {
            data.append((type: "Input", count: totalInputTokens))
        }
        if totalOutputTokens > 0 {
            data.append((type: "Output", count: totalOutputTokens))
        }
        if totalCacheCreation > 0 {
            data.append((type: "Cache Write", count: totalCacheCreation))
        }
        if totalCacheRead > 0 {
            data.append((type: "Cache Read", count: totalCacheRead))
        }

        return data
    }

    var body: some View {
        Chart(chartData, id: \.type) { item in
            SectorMark(
                angle: .value("Count", item.count),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .foregroundStyle(by: .value("Type", item.type))
            .annotation(position: .overlay) {
                Text("\(formatPercentage(item.count))")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
    }

    private func formatPercentage(_ value: Int) -> String {
        let total = totalInputTokens + totalOutputTokens + totalCacheCreation + totalCacheRead
        guard total > 0 else { return "0%" }
        let percentage = (Double(value) / Double(total)) * 100
        return String(format: "%.0f%%", percentage)
    }
}

enum StatsPeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case all = "All Time"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

enum StatsMetric: String, CaseIterable, Identifiable {
    case cost = "Cost"
    case calls = "Calls"
    case tokens = "Tokens"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

#Preview {
    StatsChartView(usageStorage: UsageStorage())
        .frame(width: 700, height: 600)
}
