// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Testbench",
  platforms: [
    .macOS(.v15)
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.2.1"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.3"),
  ],
  targets: [
    .executableTarget(
      name: "Testbench",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Subprocess", package: "swift-subprocess"),
        "DefaultsClient",
        "DateClient",
        "StorageClient",
        "Models",
      ]
    ),
    .target(
      name: "Models",
    ),
    .target(
      name: "StorageClient",
      dependencies: [
        .product(name: "Factory", package: "Factory")
      ],
      path: "Sources/Clients/StorageClient"
    ),
    .target(
      name: "DefaultsClient",
      dependencies: [
        .product(name: "Factory", package: "Factory")
      ],
      path: "Sources/Clients/DefaultsClient"
    ),
    .target(
      name: "DateClient",
      dependencies: [
        .product(name: "Factory", package: "Factory")
      ],
      path: "Sources/Clients/DateClient"
    ),
    .testTarget(
      name: "TestbenchTests",
      dependencies: [
        "Testbench"
      ]
    ),
    .testTarget(name: "SwiftTestingTests"),
    .testTarget(name: "XCTestTests"),
  ],
  swiftLanguageModes: [.v6]
)
