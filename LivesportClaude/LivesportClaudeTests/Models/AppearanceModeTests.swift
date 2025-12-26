//
//  AppearanceModeTests.swift
//  LivesportClaudeTests
//

import XCTest
import SwiftUI
@testable import LivesportClaude

final class AppearanceModeTests: XCTestCase {

    func testAllCasesCount() {
        XCTAssertEqual(AppearanceMode.allCases.count, 3)
    }

    func testAllCasesContainsExpectedModes() {
        XCTAssertTrue(AppearanceMode.allCases.contains(.system))
        XCTAssertTrue(AppearanceMode.allCases.contains(.light))
        XCTAssertTrue(AppearanceMode.allCases.contains(.dark))
    }

    func testRawValues() {
        XCTAssertEqual(AppearanceMode.system.rawValue, "system")
        XCTAssertEqual(AppearanceMode.light.rawValue, "light")
        XCTAssertEqual(AppearanceMode.dark.rawValue, "dark")
    }

    func testDisplayNames() {
        XCTAssertEqual(AppearanceMode.system.displayName, "System")
        XCTAssertEqual(AppearanceMode.light.displayName, "Light")
        XCTAssertEqual(AppearanceMode.dark.displayName, "Dark")
    }

    func testDescriptions() {
        XCTAssertEqual(AppearanceMode.system.description, "Follow system appearance")
        XCTAssertEqual(AppearanceMode.light.description, "Always use light mode")
        XCTAssertEqual(AppearanceMode.dark.description, "Always use dark mode")
    }

    func testColorSchemeMapping() {
        XCTAssertNil(AppearanceMode.system.colorScheme)
        XCTAssertEqual(AppearanceMode.light.colorScheme, .light)
        XCTAssertEqual(AppearanceMode.dark.colorScheme, .dark)
    }

    func testInitFromRawValue() {
        XCTAssertEqual(AppearanceMode(rawValue: "system"), .system)
        XCTAssertEqual(AppearanceMode(rawValue: "light"), .light)
        XCTAssertEqual(AppearanceMode(rawValue: "dark"), .dark)
        XCTAssertNil(AppearanceMode(rawValue: "invalid"))
    }

    func testIdentifiable() {
        XCTAssertEqual(AppearanceMode.system.id, "system")
        XCTAssertEqual(AppearanceMode.light.id, "light")
        XCTAssertEqual(AppearanceMode.dark.id, "dark")
    }

    func testCaseIterable() {
        let modes = AppearanceMode.allCases
        XCTAssertEqual(modes[0], .system)
        XCTAssertEqual(modes[1], .light)
        XCTAssertEqual(modes[2], .dark)
    }

    func testEquality() {
        XCTAssertEqual(AppearanceMode.system, AppearanceMode.system)
        XCTAssertEqual(AppearanceMode.light, AppearanceMode.light)
        XCTAssertEqual(AppearanceMode.dark, AppearanceMode.dark)

        XCTAssertNotEqual(AppearanceMode.system, AppearanceMode.light)
        XCTAssertNotEqual(AppearanceMode.light, AppearanceMode.dark)
        XCTAssertNotEqual(AppearanceMode.dark, AppearanceMode.system)
    }
}
