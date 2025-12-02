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
  var iterations: Int = 1 // FIXME: Bump to ten
  
  var frameworks: [TestFramework<XCTestOptions, TestingOptions>] {
    [
      .swiftTesting(
        TestingOptions(
          testPlan: self.testingPlan,
          regex: .testingTestCaseSuccess,
          ignoreRegexes: [
            .testingTestRunPassed,
            .testingTestSuite
          ]
        )
      ),
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
    let derrivedDataPath = self.storage
      .directory()
      .appending(path: "DerrivedData")
    
    for framework in self.frameworks {
      for i in 0 ..< self.iterations {
        var run = XcodebuildTestRun(framework: framework)
        if self.common.isVerbose {
          print("Framework: \(framework.description), iteration: \(i + 1)")
        }
       
        var start: DispatchTime?
        try await self.invokeXcodebuild(
          scheme: self.schema,
          derrivedDataPath: derrivedDataPath.path(),
          testPlan: run.testPlan,
          isParallelTestingEnabled: {
            switch framework {
            case .xctest:
              true
              
            case .swiftTesting:
              false
            }
          }(),
          parallelTestingWorkerCount: 2
        ) { [isVerbose = self.common.isVerbose] line in
          let testCase: TestCase?
          if isVerbose {
            print(line)
          }
          
          switch framework {
          case let .xctest(options):
            testCase = line.match(using: options.regex).testCase()
            if line.match(using: .xctestTestSuitStarted) != nil {
              start = .now()
            }
            
            if let start, line.match(using: .xctestTestSuitPassed) != nil {
              run.testRunDuration = start.distance(to: .now()).seconds
            }
            
          case let .swiftTesting(options):
            testCase = line.match(using: options.regex, ignore: options.ignoreRegexes).testCase()
            if line.match(using: .testingTestRunStarted) != nil {
              print("Starting timer at: \(line)")
              start = .now()
            }
            
            if let start, line.match(using: .testingTestRunPassed) != nil {
              print("Ending timer at: \(line)")
              run.testRunDuration = start.distance(to: .now()).seconds
            }
          }
          
          if let testCase {
            run.testCases.append(testCase)
          }
        }
        start = nil
        
        if self.common.isVerbose {
          print(String(describing: run.description))
        }
      }
    }
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
