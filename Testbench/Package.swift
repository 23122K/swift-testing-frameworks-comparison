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
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", exact: "0.17.1"),
    .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.3"),
  ],
  targets: [
    .executableTarget(
      name: "Testbench",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Factory", package: "Factory"),
        .product(name: "Subprocess", package: "swift-subprocess"),
        "Defaults",
        "Date",
        "Models",
        "Storage"
      ]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "XMLCoder", package: "XMLCoder"),
      ]
    ),
    .target(
      name: "Storage",
      dependencies: [
        .product(name: "Factory", package: "Factory")
      ],
      path: "Sources/Clients/Storage"
    ),
    .target(
      name: "Defaults",
      dependencies: [
        .product(name: "Factory", package: "Factory")
      ],
      path: "Sources/Clients/Defaults"
    ),
    .target(
      name: "Date",
      dependencies: [
        .product(name: "Factory", package: "Factory")
      ],
      path: "Sources/Clients/Date"
    ),
    .testTarget(
      name: "TestbenchTests",
      dependencies: [
        "Testbench"
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
