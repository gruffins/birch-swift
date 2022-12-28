// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Birch",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10),
        .macOS(.v10_13)
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
