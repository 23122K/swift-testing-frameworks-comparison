import ArgumentParser
import Factory
import DefaultsClient
import Subprocess
import StorageClient
import Foundation
import Models

struct XCTestOptions: @unchecked Sendable {
  let testPlan: String
  let regex: AnyRegex
}

struct TestingOptions: @unchecked Sendable {
  let testPlan: String
  let regex: AnyRegex
  let ignoreRegexes: [AnyRegex]
}

typealias XcodebuildTestRun = TestRun<XCTestOptions, TestingOptions>
extension XcodebuildTestRun {
  var testPlan: String {
    switch self.framework {
      case let .xctest(options):
        options.testPlan
        
      case let .swiftTesting(options):
        options.testPlan
    }
  }
}

struct XcodebuildCommand: AsyncParsableCommand {
  @OptionGroup
  var common: CommonOptions
  
  @Argument(help: "Schema containing test plans for both XCTest and Testing")
  var schema: String
  
  @Argument
  var destination: String = "macOS"
  
  @Option(help: "Test plan containing only tests in XCTest")
  var xctestPlan: String = "testbench-xctest"
  
  @Option(help: "Test plan containing only tests in Testing")
  var testingPlan: String = "testbench-testing"
  
  @Option(help: "Tests iterations, before each run clean build is done")
  var iterations: Int = 1 // FIXME: Bump to ten

  mutating func run() async throws {
    try await self.checkIfCanStartBenchmark()
    
    let derrivedDataPath = self.storage
      .directory()
      .appending(path: "DerrivedData")
    
    var runs = [
      XcodebuildTestRun(
        framework: .xctest(
          XCTestOptions(
            testPlan: self.xctestPlan,
            regex: .xctestTestCaseSuccess
          )
        )
      ),
      XcodebuildTestRun(
        framework: .swiftTesting(
          TestingOptions(
            testPlan: self.testingPlan,
            regex: .testingTestCaseSuccess,
            ignoreRegexes: [
              .testingTestRun,
              .testingTestSuite
            ]
          )
        )
      )
    ]
    
    for run in 0 ..< runs.count {
      for i in 0 ..< self.iterations {
        if self.common.isVerbose {
          print("Test plan: \(runs[run].testPlan), iteration: \(i + 1)")
        }
        _ = try await Subprocess.run(
          Configuration.test(
            self.schema,
            testPlan: {
              switch runs[run].framework {
                case let .swiftTesting(options):
                  options.testPlan
                  
                case let .xctest(options):
                  options.testPlan
              }
            }(),
            platform: self.destination, // FIXME: pmaciag -
            resultBundlePath: nil,
            derrivedDataPath: derrivedDataPath.path(),
            isParallelTestingEnabled: false,
            maximumConcurrentTestDeviceDestinations: 1,
            maximumConcurrentTestSimulatorDestinations: 1,
            parallelTestingWorkerCount: 1, // Even with parallel testing disabled this cant be 0
            maximumParallelTestingWorkers: 1 // Same case, can be 0
          )
        ) { _, _, outputIo, errorIo in
          for try await output in outputIo.lines() {
            if self.common.isVerbose {
              print(output)
            }
            
            let testCase: TestCase?
            switch runs[run].framework {
              case let .xctest(options):
                testCase = output.match(using: options.regex).testCase()
                
              case let .swiftTesting(options):
                testCase = output.match(using: options.regex, ignore: options.ignoreRegexes).testCase()
            }
            
            if let testCase {
              runs[run].testCases.append(testCase)
            }
          }
          
          for try await error in errorIo.lines() {
            print("Error: \(error)")
          }
        }
        
        // Clean derrived data after test itration
        try self.storage.delete(derrivedDataPath)
      }
    }
  }
  
  private func checkSimulator() async throws -> (id: String, status: String) {
    guard let (_, id, status) = try? await Subprocess.run(
        Configuration.xcrunSimctlListDevices,
        output: .string(limit: 128*128)
      )
      .standardOutput?
      .firstMatch(of: .benchmarkSimulatorUuidAndStatus)?
      .as((Substring, Substring, Substring).self)
    else { throw Failure.simulatorNotFound }
    
    return (String(id), String(status))
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
  
  private func createSimulator(
    with name: String = "Benchmark",
    device: SimDevice = .iPhone17Pro,
    runtime: SimRuntime = .iOS26_0
  ) async throws -> String {
    let result = try await Subprocess.run(
      Configuration.xcrunSimctlCreate(
        name: name,
        device: device,
        runtime: runtime
      ),
      output: .string(limit: 128*128)
    )
    
    guard let simulatorID = result.standardOutput
    else { throw Failure.simulatorNotCreated }
    return simulatorID
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

extension BidirectionalCollection where Self.SubSequence == Substring {
  func match(
    using regex: AnyRegex,
    ignore regexes: [AnyRegex] = []
  ) -> Regex<AnyRegex.RegexOutput>.Match? {
    for regex in regexes.compactMap(\.self) {
      guard self.firstMatch(of: regex) == nil
      else { return nil }
      continue
    }
    
    return self.firstMatch(of: regex)
  }
}
