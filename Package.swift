// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Framer",
    platforms: [.macOS(.v10_13)],
    products: [
        .executable(name: "framer", targets: ["Framer"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "Framer",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [.copy("Resources")]
        )
    ]
)
