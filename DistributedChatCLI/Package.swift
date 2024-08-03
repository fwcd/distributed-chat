// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DistributedChatCLI",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .executable(
            name: "distributed-chat",
            targets: ["DistributedChatCLI"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../DistributedChatKit"),
        .package(path: "../DistributedChatSimulationProtocol"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.2"),
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.6.1"),
        .package(url: "https://github.com/PureSwift/BluetoothLinux.git", .branch("master")),
        .package(url: "https://github.com/PureSwift/GATT.git", .branch("master")),
        .package(name: "LineNoise", url: "https://github.com/andybest/linenoise-swift.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DistributedChatCLI",
            dependencies: [
                .product(name: "DistributedChatKit", package: "DistributedChatKit"),
                .product(name: "DistributedChatSimulationProtocol", package: "DistributedChatSimulationProtocol"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "WebSocketKit", package: "websocket-kit"),
                // TODO: Reenable once build issues with BluetoothLinux are fixed
                // .product(name: "BluetoothLinux", package: "BluetoothLinux", condition: .when(platforms: [.linux])),
                .product(name: "GATT", package: "GATT"),
                .product(name: "LineNoise", package: "LineNoise"),
            ]
        )
    ]
)
