// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "MockLib",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "MockLib",
            targets: ["MockLib"]
        ),
    ],
    targets: [
        .target(
            name: "MockLib",
            dependencies: []
        ),
        .testTarget(
            name: "MockLibTests",
            dependencies: ["MockLib"]
        ),
    ]
)
