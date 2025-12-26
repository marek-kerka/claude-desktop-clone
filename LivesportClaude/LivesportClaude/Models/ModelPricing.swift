//
//  ModelPricing.swift
//  LivesportClaude
//

import Foundation

struct ModelPricing {
    let inputPricePerMillionTokens: Double
    let outputPricePerMillionTokens: Double
    let cacheWritePricePerMillionTokens: Double
    let cacheReadPricePerMillionTokens: Double

    init(
        inputPricePerMillionTokens: Double,
        outputPricePerMillionTokens: Double,
        cacheWritePricePerMillionTokens: Double? = nil,
        cacheReadPricePerMillionTokens: Double? = nil
    ) {
        self.inputPricePerMillionTokens = inputPricePerMillionTokens
        self.outputPricePerMillionTokens = outputPricePerMillionTokens
        self.cacheWritePricePerMillionTokens = cacheWritePricePerMillionTokens ?? (inputPricePerMillionTokens * 1.25)
        self.cacheReadPricePerMillionTokens = cacheReadPricePerMillionTokens ?? (inputPricePerMillionTokens * 0.1)
    }

    func calculateCost(
        inputTokens: Int,
        outputTokens: Int,
        cacheCreationTokens: Int = 0,
        cacheReadTokens: Int = 0
    ) -> Double {
        let inputCost = Double(inputTokens) / 1_000_000.0 * inputPricePerMillionTokens
        let outputCost = Double(outputTokens) / 1_000_000.0 * outputPricePerMillionTokens
        let cacheWriteCost = Double(cacheCreationTokens) / 1_000_000.0 * cacheWritePricePerMillionTokens
        let cacheReadCost = Double(cacheReadTokens) / 1_000_000.0 * cacheReadPricePerMillionTokens
        return inputCost + outputCost + cacheWriteCost + cacheReadCost
    }

    static let pricing: [String: ModelPricing] = [
        ClaudeModel.haiku.rawValue: ModelPricing(
            inputPricePerMillionTokens: 0.25,
            outputPricePerMillionTokens: 1.25
        ),
        ClaudeModel.sonnet.rawValue: ModelPricing(
            inputPricePerMillionTokens: 3.0,
            outputPricePerMillionTokens: 15.0
        ),
        ClaudeModel.opus.rawValue: ModelPricing(
            inputPricePerMillionTokens: 15.0,
            outputPricePerMillionTokens: 75.0
        )
    ]

    static func getCost(
        model: ClaudeModel,
        inputTokens: Int,
        outputTokens: Int,
        cacheCreationTokens: Int = 0,
        cacheReadTokens: Int = 0
    ) -> Double {
        guard let pricing = pricing[model.rawValue] else {
            return 0.0
        }
        return pricing.calculateCost(
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: cacheCreationTokens,
            cacheReadTokens: cacheReadTokens
        )
    }
}
