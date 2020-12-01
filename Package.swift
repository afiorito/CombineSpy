// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CombineSpy",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15"),
        .tvOS("13.0"),
    ],
    products: [
        .library(
            name: "CombineSpy",
            targets: ["CombineSpy"]
        ),
    ],
    targets: [
        .target(
            name: "CombineSpy",
            dependencies: []
        ),
        .testTarget(
            name: "CombineSpyTests",
            dependencies: ["CombineSpy"]
        ),
    ]
)
