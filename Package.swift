// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LivesportClaude",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "LivesportClaude",
            targets: ["LivesportClaude"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "LivesportClaude",
            dependencies: [],
            path: "LivesportClaude/LivesportClaude",
            exclude: ["Info.plist", "Resources/Assets.xcassets"],
            sources: [
                "App",
                "Models",
                "Services",
                "Views"
            ]
        ),
        .testTarget(
            name: "LivesportClaudeTests",
            dependencies: ["LivesportClaude"],
            path: "LivesportClaude/LivesportClaudeTests",
            exclude: ["Info.plist"]
        ),
    ]
)
