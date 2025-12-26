//
//  ModelPricingTests.swift
//  LivesportClaudeTests
//

import XCTest
@testable import LivesportClaude

final class ModelPricingTests: XCTestCase {

    func testHaikuPricing() {
        let pricing = ModelPricing.pricing[ClaudeModel.haiku.rawValue]
        XCTAssertNotNil(pricing)
        XCTAssertEqual(pricing?.inputPricePerMillionTokens, 0.25)
        XCTAssertEqual(pricing?.outputPricePerMillionTokens, 1.25)
    }

    func testSonnetPricing() {
        let pricing = ModelPricing.pricing[ClaudeModel.sonnet.rawValue]
        XCTAssertNotNil(pricing)
        XCTAssertEqual(pricing?.inputPricePerMillionTokens, 3.0)
        XCTAssertEqual(pricing?.outputPricePerMillionTokens, 15.0)
    }

    func testOpusPricing() {
        let pricing = ModelPricing.pricing[ClaudeModel.opus.rawValue]
        XCTAssertNotNil(pricing)
        XCTAssertEqual(pricing?.inputPricePerMillionTokens, 15.0)
        XCTAssertEqual(pricing?.outputPricePerMillionTokens, 75.0)
    }


    func testCalculateCost() {
        let pricing = ModelPricing(
            inputPricePerMillionTokens: 3.0,
            outputPricePerMillionTokens: 15.0
        )

        let cost = pricing.calculateCost(inputTokens: 1000, outputTokens: 1000)
        let expectedCost = (1000.0 / 1_000_000.0 * 3.0) + (1000.0 / 1_000_000.0 * 15.0)
        XCTAssertEqual(cost, expectedCost, accuracy: 0.0001)
    }

    func testGetCostForSonnet() {
        let cost = ModelPricing.getCost(
            model: .sonnet,
            inputTokens: 100_000,
            outputTokens: 50_000
        )

        let expectedCost = (100_000.0 / 1_000_000.0 * 3.0) + (50_000.0 / 1_000_000.0 * 15.0)
        XCTAssertEqual(cost, expectedCost, accuracy: 0.0001)
    }

    func testGetCostForOpus() {
        let cost = ModelPricing.getCost(
            model: .opus,
            inputTokens: 10_000,
            outputTokens: 5_000
        )

        let expectedCost = (10_000.0 / 1_000_000.0 * 15.0) + (5_000.0 / 1_000_000.0 * 75.0)
        XCTAssertEqual(cost, expectedCost, accuracy: 0.0001)
    }


    func testZeroTokensCost() {
        let cost = ModelPricing.getCost(
            model: .sonnet,
            inputTokens: 0,
            outputTokens: 0
        )

        XCTAssertEqual(cost, 0.0)
    }
}
