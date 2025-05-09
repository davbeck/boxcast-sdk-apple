// swift-tools-version:6.0

import PackageDescription

let package = Package(
	name: "BoxCast",
	platforms: [
		.iOS(.v13),
		.tvOS(.v13),
		.macOS(.v10_15),
	],
	products: [
		.library(
			name: "BoxCast",
			targets: ["BoxCast"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.55.0"),
	],
	targets: [
		.target(
			name: "BoxCast",
			dependencies: [],
			path: "./Source",
			exclude: [
				"Info.plist",
			]
		),
		.testTarget(
			name: "BoxCast-Tests",
			dependencies: ["BoxCast"],
			path: "./Tests",
			exclude: [
				"Info.plist",
			],
			resources: [
				.copy("Fixtures"),
			],
			swiftSettings: [
				.swiftLanguageMode(.v5),
			]
		),
	]
)
