// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-test-benchmark",
  platforms: [
    .macOS(.v15)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", exact: "0.1.0"),
    .package(url: "https://github.com/CoreOffice/XMLCoder.git", exact: "0.17.1"),
  ],
  targets: [
    .executableTarget(
      name: "swift-test-benchmark",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Subprocess", package: "swift-subprocess"),
        .product(name: "XMLCoder", package: "XMLCoder"),
      ]
    )
  ]
)
