// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Birch",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Birch",
            targets: ["Birch"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Birch",
            dependencies: []),
    ]
)
