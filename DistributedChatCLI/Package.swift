// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DistributedChatCLI",
    products: [
        .executable(
            name: "DistributedChatCLI",
            targets: ["DistributedChatCLI"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../DistributedChat"),
        .package(path: "../DistributedChatSimulationProtocol"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.2"),
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.1.2"),
        .package(url: "https://github.com/PureSwift/BluetoothLinux.git", .revision("e9dd7332b5ac92c09d3d9ff9244ac535afc5f493")),
        // TODO: Use upstream again once https://github.com/PureSwift/GATT/issues/24 and https://github.com/PureSwift/GATT/pull/27 are merged
        // .package(url: "https://github.com/PureSwift/GATT.git", .revision("c3bbda8000e3b82486ca9a353725d1bfbc7701e8")),
        .package(name: "GATT", url: "https://github.com/fwcd/swift-gatt.git", .revision("787c31bcb5da3b3217b1400cce56cda00f6df1e0")),
        .package(name: "LineNoise", url: "https://github.com/andybest/linenoise-swift.git", .revision("78e9bc9b685ffd551af0f3ac4d6e2beb22afd33b")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DistributedChatCLI",
            dependencies: [
                .product(name: "DistributedChat", package: "DistributedChat"),
                .product(name: "DistributedChatSimulationProtocol", package: "DistributedChatSimulationProtocol"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "BluetoothLinux", package: "BluetoothLinux"),
                .product(name: "GATT", package: "GATT"),
                .product(name: "LineNoise", package: "LineNoise"),
            ]
        )
    ]
)
