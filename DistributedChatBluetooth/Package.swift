// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var packageDependencies: [Package.Dependency] = [
    .package(path: "../DistributedChatKit"),
]

var targetDependencies: [Target.Dependency] = [
    .product(name: "DistributedChatKit", package: "DistributedChatKit"),
]

#if os(Linux)
packageDependencies += [
    .package(url: "https://github.com/PureSwift/BluetoothLinux.git", .branch("master")),
    .package(url: "https://github.com/PureSwift/GATT.git", .branch("master")),
]

targetDependencies += [
    .product(name: "BluetoothLinux", package: "BluetoothLinux", condition: .when(platforms: [.linux])),
    .product(name: "GATT", package: "GATT", condition: .when(platforms: [.linux])),
]
#endif

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
    dependencies: packageDependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DistributedChatBluetooth",
            dependencies: targetDependencies
        ),
        .testTarget(
            name: "DistributedChatBluetoothTests",
            dependencies: ["DistributedChatBluetooth"]
        ),
    ]
)
