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
  
  @Argument
  var destination: String = "macOS"
  
  @Option(help: "XCTest test plan name")
  var xctestPlan: String = "testbench-xctest"
  
  @Option(help: "Swift Testing test plan name")
  var testingPlan: String = "testbench-testing"
  
  @Option(help: "Tests iterations, before each run clean build is done")
  var iterations: Int = 10
  
  var frameworks: [TestFramework<XCTestOptions, TestingOptions>] {
    [
      .xctest(
        XCTestOptions(
          testPlan: self.xctestPlan,
          regex: .xctestTestCaseSuccess
        )
      )
    ]
  }

  mutating func run() async throws {
    try await self.checkIfCanStartBenchmark()
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
  fileprivate var storage: StorageClient {
    @Injected(\.storage) var storage
    return storage
  }
  
  fileprivate var defaults: DefaultsClient {
    @Injected(\.defaults) var defaults
    return defaults
  }
}
