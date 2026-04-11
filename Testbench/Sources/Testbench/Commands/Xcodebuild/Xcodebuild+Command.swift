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

  @Flag(
    name: [.customLong("force"), .customShort("f")],
    help: "Purge any existing results for this schema without prompting."
  )
  var force: Bool = false

  @Option(help: "Tests iterations, before each run clean build is done")
  var iterations: Int = 10
  
  mutating func run() async throws {
    try await self.checkIfCanStartBenchmark()
    try self.checkAndPurgeExistingResults()

    let derrivedData = self.storage
      .directory()
      .appending(path: "DerrivedData")

    let path = try await self.xcodebuildBuildForTesting(
      scheme: self.schema,
      derrivedData: derrivedData
    )
    
    let bundles = try self.storage
      .contentsOfDirectory(path)
      .filter { file in
        file.hasSuffix(".xctest")
      }
      .map { file in
        path.appending(path: file)
      }
    
    for bundle in bundles {
      print("Bundle: \(bundle.path())")
    }

    try await self.runXCTestBundles(bundles)
  }
  
  /// Checks whether previous xcodebuild results exist for this schema.
  /// Purges them when --force is set; otherwise exits with an error.
  private func checkAndPurgeExistingResults() throws {
    let schemaResultsDir = self.storage
      .directory()
      .appending(path: "xcodebuild")
      .appending(path: self.schema)

    let contents: [String]
    do {
      contents = try self.storage.contentsOfDirectory(schemaResultsDir)
    } catch {
      return
    }

    if contents.isEmpty {
      return
    }

    guard self.force else {
      throw XcodebuildError.resultsAlreadyExist(scheme: self.schema, path: schemaResultsDir.path())
    }

    try self.storage.delete(schemaResultsDir)
    print("Existing results purged (--force).")
  }

  private func checkIfCanStartBenchmark() async throws {
    guard try self.defaults.bool(forKey: .isReportGenerated) else {
      print("Report not generated, generation raport now...")
      print("Please run testbench report --generate to continue")
      return
    }
    
    guard let _: String = try self.defaults.get(forKey: .repositoryURL) else {
      print("Path not set, set path to swift-testing-frameworks-comparison before continguing")
      print("Please run testbench --set-path <PATH> to continue")
      return
    }
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
