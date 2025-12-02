import ArgumentParser
import Factory
import DefaultsClient
import Subprocess
import StorageClient
import Foundation
import Models

struct XCTestOptions: Sendable, Encodable {
  let testPlan: String
  let regex: AnyRegex
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.testPlan)
  }
}

struct TestingOptions: Sendable {
  let testPlan: String
  let regex: AnyRegex
  let ignoreRegexes: [AnyRegex]
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.testPlan)
  }
}

struct TestSummary: Sendable, Codable {
  let testPlan: String
  let framework: String
  let testCases: [TestCase]
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
  
  var summary: TestSummary {
    TestSummary(
      testPlan: self.testPlan,
      framework: self.framework.description,
      testCases: self.testCases
    )
  }
}

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

  mutating func run() async throws {
    try await self.checkIfCanStartBenchmark()
    let derrivedDataPath = self.storage
      .directory()
      .appending(path: "DerrivedData")
    
    let frameworks: [TestFramework<XCTestOptions, TestingOptions>] = [
      .swiftTesting(
        TestingOptions(
          testPlan: self.testingPlan,
          regex: .testingTestCaseSuccess,
          ignoreRegexes: [
            .testingTestRun,
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
    
    for framework in frameworks {
      for i in 0 ..< self.iterations {
        var run = XcodebuildTestRun(framework: framework)
        if self.common.isVerbose {
          print("Framework: \(framework.description), iteration: \(i + 1)")
        }
        
        try await self.invokeXcodebuild(
          scheme: self.schema,
          testPlan: run.testPlan
        ) { line in
          let testCase: TestCase?
          switch framework {
          case let .xctest(options):
            testCase = line.match(using: options.regex).testCase()
            
          case let .swiftTesting(options):
            testCase = line.match(using: options.regex, ignore: options.ignoreRegexes).testCase()
          }
          
          if let testCase {
            run.testCases.append(testCase)
          }
        }
        
        print(run.totalTestDuration)
        
//        let runResult = try await Subprocess.run(
//          Configuration.test(
//            self.schema,
//            testPlan: {
//              switch framework {
//                case let .swiftTesting(options):
//                  options.testPlan
//                  
//                case let .xctest(options):
//                  options.testPlan
//              }
//            }(),
//            platform: self.destination, // FIXME: pmaciag -
//            resultBundlePath: nil,
//            derrivedDataPath: derrivedDataPath.path(),
//            isParallelTestingEnabled: false,
//            maximumConcurrentTestDeviceDestinations: 1,
//            maximumConcurrentTestSimulatorDestinations: 1,
//            parallelTestingWorkerCount: 1,
//            maximumParallelTestingWorkers: 1
//          )
//        ) { exec, outputIo in
//          for try await buffer in outputIo {
//            let rawSpan = buffer.bytes
//            var array: [UInt8] = []
//            for index in 0..<rawSpan.byteCount {
//                array.append(rawSpan.unsafeLoad(fromByteOffset: index, as: UInt8.self))
//            }
//            
//            let output = String(decodingBytes: array, as2: Unicode.UTF8.self)
//            print(output)
//            
//            let testCase: TestCase?
//            switch framework {
//            case let .xctest(options):
//              testCase = output.match(using: options.regex).testCase()
//              
//            case let .swiftTesting(options):
//              testCase = output.match(using: options.regex, ignore: options.ignoreRegexes).testCase()
//            }
//            
//            if let testCase {
//              run.testCases.append(testCase)
//            }
//          }
//        }
        

        // Clean derrived data after test itration
//        do {
//          try self.storage.delete(derrivedDataPath)
//          try self.storage.write(run.summary, name: "\(run.testPlan)-iteration-\(i+1).json")
//        } catch {
//          print(error)
//        }
      }
    }
  }
  
  private func invokeXcodebuild(
    scheme: String,
    destination: String = "platform=macOS,arch=arm64,name=My Mac",
    derrivedDataPath: String? = nil,
    resultBundlePath: String? = nil,
    testPlan: String,
    shouldSkipPackagePluginValidation: Bool = true,
    shouldSkipMacroValidation: Bool = true,
    isParallelTestingEnabled: Bool = false,
    parallelTestingWorkerCount: Int = 1,
    _ output: @escaping (String) -> Void
  ) async throws {
    let process = Process()
    let standardOutput = Pipe()
    process.standardOutput = standardOutput
    process.executableURL = try await self.getXcodePath()
      .appending(path: "usr")
      .appending(path: "bin")
      .appending(path: "xcodebuild")
    
    process.arguments = arguments {
      "test"
      "-scheme"; self.schema
      "-destination"; "platform=macOS,arch=arm64,name=My Mac"
      if let derrivedDataPath {
        "-derivedDataPath"; "\(derrivedDataPath)"
      }
      
      if let resultBundlePath {
        "-resultBundlePath"; "\(resultBundlePath)"
      }
      "-testPlan"; "\(testPlan)"
      if shouldSkipPackagePluginValidation {
        "-skipPackagePluginValidation"
      }
      if shouldSkipMacroValidation {
        "-skipMacroValidation"
      }
      "-parallel-testing-enabled"; isParallelTestingEnabled ? "YES" : "NO"
      "-parallel-testing-worker-count"; "\(parallelTestingWorkerCount)"
    }
    
    try process.run()
    for try await line in standardOutput.fileHandleForReading.bytes.lines {
      output(line)
    }
  }
  
  private func getXcodePath() async throws -> URL {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
    process.arguments = arguments {
      "--print-path"
    }
    
    let standardOutput = Pipe()
    process.standardOutput = standardOutput
    try process.run()
    
    guard
      let filePath = try await standardOutput.fileHandleForReading.bytes.lines.first(where: { _ in true })
    else { fatalError("WIP") }
    
    return URL(filePath: filePath)
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

extension DispatchTimeInterval {
  var seconds: Double {
    switch self {
    case let .seconds(value):
      return Double(value)
      
    case let .milliseconds(value):
      return Double(value) / 1_000
      
    case let .microseconds(value):
      return Double(value) / 1_000_000
      
    case let .nanoseconds(value):
      return Double(value) / 1_000_000_000
    
    default:
      return 0.0
    }
  }
}
