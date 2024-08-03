// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DistributedChatBluetooth",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DistributedChatBluetooth",
            targets: ["DistributedChatBluetooth"]
        ),
    ],
    dependencies: [
        .package(path: "../DistributedChatKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DistributedChatBluetooth",
            dependencies: [
                .product(name: "DistributedChatKit", package: "DistributedChatKit"),
            ]
        ),
        .testTarget(
            name: "DistributedChatBluetoothTests",
            dependencies: ["DistributedChatBluetooth"]
        ),
    ]
)
