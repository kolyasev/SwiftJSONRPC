// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftJSONRPC",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftJSONRPC",
            targets: ["SwiftJSONRPC"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftJSONRPC",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftJSONRPCTests",
            dependencies: ["SwiftJSONRPC"],
            path: "Tests"
        ),
    ]
)
