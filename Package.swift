// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LivesportClaude",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "LivesportClaude",
            targets: ["LivesportClaude"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "LivesportClaude",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
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
