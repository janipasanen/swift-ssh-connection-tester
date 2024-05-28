// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ssh-connection-tester",
    platforms: [
            .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio-ssh/", from: "0.3.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-ssh-connection-tester",
            dependencies: [
                .product(name: "NIOSSH", package: "swift-nio-ssh"),
            ]
        ),
    ]
)
