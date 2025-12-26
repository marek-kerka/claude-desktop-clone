//
//  ModelPricing.swift
//  LivesportClaude
//

import Foundation

struct ModelPricing {
    let inputPricePerMillionTokens: Double
    let outputPricePerMillionTokens: Double

    func calculateCost(inputTokens: Int, outputTokens: Int) -> Double {
        let inputCost = Double(inputTokens) / 1_000_000.0 * inputPricePerMillionTokens
        let outputCost = Double(outputTokens) / 1_000_000.0 * outputPricePerMillionTokens
        return inputCost + outputCost
    }

    static let pricing: [String: ModelPricing] = [
        ClaudeModel.sonnet.rawValue: ModelPricing(
            inputPricePerMillionTokens: 3.0,
            outputPricePerMillionTokens: 15.0
        ),
        ClaudeModel.opus.rawValue: ModelPricing(
            inputPricePerMillionTokens: 15.0,
            outputPricePerMillionTokens: 75.0
        )
    ]

    static func getCost(model: ClaudeModel, inputTokens: Int, outputTokens: Int) -> Double {
        guard let pricing = pricing[model.rawValue] else {
            return 0.0
        }
        return pricing.calculateCost(inputTokens: inputTokens, outputTokens: outputTokens)
    }
}
