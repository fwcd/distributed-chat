// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DistributedChatSimulationServer",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "DistributedChatSimulationServer",
            targets: ["DistributedChatSimulationServer"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../DistributedChat"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DistributedChatSimulationServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "DistributedChatSimulationServerTests",
            dependencies: ["DistributedChatSimulationServer"]
        )
    ]
)
