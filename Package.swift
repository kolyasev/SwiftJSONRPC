// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftJSONRPC",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "SwiftJSONRPC",
            targets: ["SwiftJSONRPC"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.9.1"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.10.0")
    ],
    targets: [
        .target(
            name: "SwiftJSONRPC",
            dependencies: ["Alamofire", "PromiseKit"],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftJSONRPCTests",
            dependencies: ["SwiftJSONRPC"],
            path: "Tests"
        ),
    ]
)
