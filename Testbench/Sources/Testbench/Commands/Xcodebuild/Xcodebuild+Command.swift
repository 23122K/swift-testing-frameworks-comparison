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
  
  @Flag(name: .customShort("p"))
  var isParallelTestingEnabled: Bool = false

  @Flag(
    name: [.customLong("force"), .customShort("f")],
    help: "Purge any existing results for this schema without prompting."
  )
  var force: Bool = false

  @Option(help: "Tests iterations, before each run clean build is done")
  var iterations: Int = 10
  
  mutating func run() async throws {
    try await self.checkIfCanStartBenchmark()
    guard try self.checkAndPurgeExistingResults() else { return }
    
    print("1: \(self.isParallelTestingEnabled)")
    let derrivedData = self.storage
      .directory()
      .appending(path: "DerrivedData")
    
    let path = try await self.xcodebuildBuildForTesting(
      scheme: self.schema,
      derrivedData: derrivedData,
      isParallelTestingEnabled: true,
      parallelTestingWorkerCount: 4
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
  /// If they do, warns the user and asks for confirmation (or purges immediately when --force is set).
  /// Returns `false` if the user chose to abort.
  private func checkAndPurgeExistingResults() throws -> Bool {
    let schemaResultsDir = self.storage
      .directory()
      .appending(path: "xcodebuild")
      .appending(path: self.schema)

    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(
      atPath: schemaResultsDir.path(),
      isDirectory: &isDirectory
    )

    guard exists, isDirectory.boolValue else { return true }

    let contents = try FileManager.default.contentsOfDirectory(atPath: schemaResultsDir.path())
    guard !contents.isEmpty else { return true }

    print("Warning: existing results for schema '\(self.schema)' found at:")
    print("  \(schemaResultsDir.path())")
    print("Running again will overwrite them. Mixed old and new iterations can corrupt comparisons.")

    if self.force {
      try FileManager.default.removeItem(at: schemaResultsDir)
      print("Existing results purged (--force).")
      return true
    }

    print("Purge existing results and continue? [y/N]: ", terminator: "")

    let answer = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
    guard answer == "y" || answer == "yes" else {
      print("Aborted. Re-run with --force / -f to purge automatically.")
      return false
    }

    try FileManager.default.removeItem(at: schemaResultsDir)
    print("Existing results purged.")
    return true
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
