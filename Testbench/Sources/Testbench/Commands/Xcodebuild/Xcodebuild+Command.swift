import ArgumentParser
import Factory
import DefaultsClient
import Subprocess
import StorageClient
import Foundation
import Models

struct XcodebuildCommand: AsyncParsableCommand {
  @OptionGroup
  var common: CommonOptions

  @Argument(help: "Schema containing test plans for both XCTest and Testing")
  var schema: String

  mutating func run() async throws {
    guard let repoPath: String = try self.defaults.get(forKey: .repositoryURL) else {
      print("Repository path not set. Run: testbench --set-path <PATH>")
      return
    }
    let repositoryURL = URL(filePath: repoPath, directoryHint: .isDirectory)

    let derivedData = self.storage
      .directory()
      .appending(path: "DerivedData")

    try? self.storage.delete(derivedData)

    let buildPath = try await self.xcodebuildBuildForTesting(
      scheme: self.schema,
      derivedData: derivedData
    )

    let bundles = try self.storage
      .contentsOfDirectory(buildPath)
      .filter { $0.hasSuffix(".xctest") }
      .map { buildPath.appending(path: $0) }

    let artifactsDir = repositoryURL
      .appending(path: "Artifacts")
      .appending(path: self.schema)

    try self.storage.createDirectory(artifactsDir)

    for bundle in bundles {
      let destination = artifactsDir.appending(path: bundle.lastPathComponent)
      try? self.storage.delete(destination)
      try self.storage.copy(bundle, destination)
      print("Artifact: \(bundle.lastPathComponent)")
    }

    print("Artifacts written to: \(artifactsDir.path())")
    print("Run tests with: testbench xctest")
  }
}

extension XcodebuildCommand {
  var storage: StorageClient {
    @Injected(\.storage) var storage
    return storage
  }

  fileprivate var defaults: DefaultsClient {
    @Injected(\.defaults) var defaults
    return defaults
  }
}
