import ArgumentParser
import Factory
import Defaults
import Subprocess
import Storage
import Foundation
import Models

struct XCTestCommand: AsyncParsableCommand {
  @Argument(help: "The name fo the Schema containing test plans")
  var schema: String
  
  @Argument
  var platform: String = "macOS"
  
  @Argument(help: "Overrides default test plan name.")
  var testPlan: String = "swift-loggable-tests"
  
  @Option(help: "Tests iterations, before each run clean build is done")
  var iterations: Int = 10

  mutating func run() async throws {
    guard try self.defaults.bool(forKey: .isReportGenerated) else {
      print("Report not generated, generation raport now...")
      print("Please run testbench report --generate to continue")
      return
    }
  
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
    for iteration in 0 ..< self.iterations {
      let resultBundlePath = self.resultBundlePath(for: iteration)
      let derrivedDataPath = self.derrivedDataPath(for: iteration)
      
      _ = try await Subprocess.run(
        Configuration.test(
          self.schema,
          testPlan: self.testPlan,
          platform: self.platform,
          resultBundlePath: resultBundlePath.path(),
          derrivedDataPath: derrivedDataPath.path()
        ),
      ) { execution, _, outputIO, errorIO in
        print(execution.processIdentifier.debugDescription)
        
        for try await line in outputIO.lines() {
          print(line)
        }
        
        for try await line in errorIO.lines() {
          print(line)
        }
      }
      
      resultBundlePaths.append(resultBundlePath)
    }

    let convertedXcresultDirectory = self.storage.directory()
      .appendingPathComponent("\(self.schema)-\(self.testPlan)-results")
    
    var xcresults: [Xcresult] = []
    for resultBundlePath in resultBundlePaths {
      let xcresult = try await self.convertXcresultToJson(resultBundlePath)
      
      xcresults.append(xcresult)
    }
    
    for xcresult in xcresults {
      print("Total test duration: ", terminator: "")
//      print(xcresult.summary.totalTestsDuration)
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
      .appending(path: "Xcresults")
      .appending(path: "\(UUID().uuidString)-\(iteration)")
      .appendingPathExtension("xcresult")
  }
  
  private func derrivedDataPath(for iteration: Int) -> URL {
    self.storage
      .directory()
      .appending(path: "DerrivedData")
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
