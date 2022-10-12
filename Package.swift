// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BoxCast",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "BoxCast",
            targets: ["BoxCast"]),
    ],
    targets: [
        .target(
            name: "BoxCast",
            dependencies: [],
            path: "./Source",
            exclude: [
                "Info.plist",
            ]),
        .testTarget(
            name: "BoxCast-Tests",
            dependencies: ["BoxCast"],
            path: "./Tests",
            exclude: [
                "Info.plist",
            ],
            resources: [
                .copy("Fixtures")
            ]
        ),
    ]
)
