import ArgumentParser
import Factory
import Defaults
import Subprocess
import Storage
import Foundation
import Models

struct XCTestCommand: AsyncParsableCommand {
  @Flag(
    name: .customShort("d")
  )
  var verbose: Bool = false // TODO: Flags starting with "v" are omited
  
  @Argument(
    help: "The name fo the Schema containing xctest-benchmark.xctestplan"
  )
  var schema: String
  
  @Argument
  var platform: String
  
  @Argument(
    help: "Overrides default test plan name."
  )
  var testPlan: String = "xctest-benchmark"
  
  @Option(
    help: "Tests iterations, before each run clean build is done"
  )
  var iterations: Int = 10
  
  var storage: Storage {
    @Injected(\.storage) var storage
    return storage
  }
  
  var defaults: Defaults {
    @Injected(\.defaults) var defaults
    return defaults
  }

  mutating func run() async throws {
//    let simulatorID: String
//    do {
//      if self.verbose {
//        print("Checking for simulator existance")
//      }
//      (simulatorID, _) = try await self.checkSimulator()
//    } catch Failure.simulatorNotFound {
//      if self.verbose {
//        print("Simulator not found, crating new simulator...")
//      }
//      simulatorID = try await self.createSimulator()
//    }
    

    var resultBundlePaths: [URL] = []
    for iteration in 0..<self.iterations {
      let resultBundlePath = self.resultBundlePath(for: iteration)
      _ = try await Subprocess.run(
        Configuration.xcodebuild(
          self.schema,
          testPlan: self.testPlan,
          platform: self.platform,
          simulatorID: "00008103-001961CA029A001E",
          resultBundlePath: resultBundlePath.path()
        )
      ) { _, _, _, _ in }
      resultBundlePaths.append(resultBundlePath)
    }

    var xcresults: [Xcresult] = []
    for resultBundlePath in resultBundlePaths {
      let xcresult = try await self.convertXcresultToJson(resultBundlePath)
      xcresults.append(xcresult)
    }
    
    for xcresult in xcresults {
      print("Total test duration: ", terminator: "")
      print(xcresult.summary.totalTestsDuration)
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
  
  private func resultBundlePath(for iteration: Int) -> URL {
    self.storage
      .directory()
      .appending(path: "xctest-iteration-\(iteration)")
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
