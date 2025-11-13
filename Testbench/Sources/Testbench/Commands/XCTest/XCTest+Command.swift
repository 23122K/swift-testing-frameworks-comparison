import ArgumentParser
import Factory
import Defaults
import Subprocess
import Storage
import Foundation
import Models

public enum TestFramework: String {
  case xctest
  case testing
}

public struct TestCase {
  public let identifier: String
  public let duration: Double
}

public protocol TestResult {
  var framework: TestFramework { get }
  var testCases: [TestCase] { get }
}

extension TestResult {
  public var description: String {
    """
    Framework: \(self.framework.rawValue)
    Test cases:
    \(self._testCasesDescription)
    """
  }
  
  private var _testCasesDescription: String {
    self.testCases.map {
      "\tIdentifier: \($0.identifier), duration: \($0.duration)"
    }.joined(separator: "\n")
  }
}

extension TestResult {
  public var testCount: Int {
    self.testCases.count
  }
  
  public var totalTestDuration: Double {
    self.testCases.reduce(into: 0.0) {
      $0 += $1.duration
    }
  }
}

enum XcodebuildFramwork {
  case xctest
  case testing
}

struct XcodebuildTestResult: TestResult {
  let framework: TestFramework
  var testCases: [TestCase]
  
  public init(
    framework: TestFramework,
    testCases: [TestCase] = []
  ) {
    self.framework = framework
    self.testCases = testCases
  }
}


struct XCTestCommand: AsyncParsableCommand {
  @Flag(
    name: [
      .customShort("v"),
      .customLong("verbose")
    ],
    help: "Show verbose logging output"
  )
  var isVerbose: Bool = false
  
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
    
    var testResults = [
      self.xctestPlan: XcodebuildTestResult(framework: .xctest),
      self.testingPlan: XcodebuildTestResult(framework: .testing)
    ]
    
    var testRegexes = [
      self.xctestPlan: AnyRegex.xctestSuccess,
      self.testingPlan: AnyRegex.testingTestCaseSuccess
    ]
    
    for testPlan in [self.xctestPlan, self.testingPlan] {
      for _ in 0 ..< self.iterations {
        _ = try await Subprocess.run(
          Configuration.test(
            self.schema,
            testPlan: testPlan,
            platform: self.destination, // FIXME: pmaciag -
            resultBundlePath: nil,
            derrivedDataPath: derrivedDataPath.path()
          )
        ) { _, _, outputIo, errorIo in
          for try await output in outputIo.lines() {
            if self.isVerbose {
              print(output)
            }
            
            guard
              let regex = testRegexes[testPlan],
              let testCase = output.match(
                using: regex,
                ignore: testPlan == self.testingPlan ? .testingTestRun : nil
              ).testCase()
            else { continue }
            testResults[testPlan]?.testCases.append(testCase)
          }
          
          for try await error in errorIo.lines() {
            print("Error: \(error)")
          }
        }
        
        // Clean derrived data after test itration
        try self.storage.delete(derrivedDataPath)
      }
    }
    
    for (key, value) in testResults {
      print("Running test plan: \(key)")
      print("Finished running \(value.testCount) in \(value.totalTestDuration)")
      print(value.description)
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
  
  private func resultBundlePath(
    for iteration: Int,
    testPlan: String
  ) -> URL {
    self.storage
      .directory()
      .appending(path: testPlan.capitalized)
      .appending(path: "\(UUID().uuidString)-\(iteration)")
      .appendingPathExtension("xcresult")
  }
  
  @discardableResult
  private func convertXcresultToJson(
    _ url: URL,
    decoder: JSONDecoder = JSONDecoder()
  ) async throws -> Xcresult {
    let data = try await Subprocess.run(
      Configuration.convertXcresultToJson(at: url),
      output: .data(limit: 1024*1024*5)
    )
    .standardOutput
    
    let xcresult = try decoder.decode(Xcresult.self, from: data)
    let name = url
      .deletingPathExtension()
      .appendingPathExtension("json")
      .lastPathComponent
    
    try self.storage.write(xcresult, name: name)
    return xcresult
  }
}

extension XCTestCommand {
  fileprivate var storage: Storage {
    @Injected(\.storage) var storage
    return storage
  }
  
  fileprivate var defaults: Defaults {
    @Injected(\.defaults) var defaults
    return defaults
  }
}

extension BidirectionalCollection where Self.SubSequence == Substring {
  func match(
    using regex: AnyRegex,
    ignore regexes: AnyRegex?...
  ) -> Regex<AnyRegex.RegexOutput>.Match? {
    for regex in regexes.compactMap(\.self) {
      guard self.firstMatch(of: regex) == nil
      else { return nil }
      continue
    }
    
    return self.firstMatch(of: regex)
  }
}
