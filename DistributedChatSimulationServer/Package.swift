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
            targets: ["DistributedChatSimulationServerMain"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../DistributedChatSimulationProtocol"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DistributedChatSimulationServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "DistributedChatSimulationProtocol", package: "DistributedChatSimulationProtocol")
            ]
        ),
        .target(
            name: "DistributedChatSimulationServerMain",
            dependencies: [
                .target(name: "DistributedChatSimulationServer")
            ]
        ),
        .testTarget(
            name: "DistributedChatSimulationServerTests",
            dependencies: [
                .target(name: "DistributedChatSimulationServer"),
                .product(name: "XCTVapor", package: "vapor"),
            ]
        )
    ]
)
