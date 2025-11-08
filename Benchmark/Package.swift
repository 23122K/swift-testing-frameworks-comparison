// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Benchmark",
  platforms: [
    .macOS(.v15)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", exact: "0.1.0"),
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", exact: "0.17.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.10.0")
  ],
  targets: [
    .executableTarget(
      name: "Benchmark",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Subprocess", package: "swift-subprocess"),
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
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "Defaults",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    )
  ],
  swiftLanguageModes: [.v6]
)
