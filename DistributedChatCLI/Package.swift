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
            name: "DistributedChatCLI",
            targets: ["DistributedChatCLI"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../DistributedChat"),
        .package(path: "../DistributedChatSimulationProtocol"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.2"),
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.6.1"),
        .package(url: "https://github.com/PureSwift/BluetoothLinux.git", .revision("b086cec00bae14ff7e49508ae0328d37e1c7c5fc")),
        .package(url: "https://github.com/PureSwift/GATT.git", .revision("0bf40a7e52cfed3d8740b0a1fea776f9f338aa9c")),
        .package(name: "LineNoise", url: "https://github.com/andybest/linenoise-swift.git", .revision("cbf0a35c6e159e4fe6a03f76c8a17ef08e907b0e")),
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
                // TODO: Reenable once build issues with BluetoothLinux are fixed
                // .product(name: "BluetoothLinux", package: "BluetoothLinux", condition: .when(platforms: [.linux])),
                .product(name: "GATT", package: "GATT"),
                .product(name: "LineNoise", package: "LineNoise"),
            ]
        )
    ]
)
