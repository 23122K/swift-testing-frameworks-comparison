import ArgumentParser
import Subprocess
import Storage
import Foundation

struct TestCommand: AsyncParsableCommand {
  @Option(help: "Schema name to be tested")
  var schema: String = "bitchat (iOS)"
  
  mutating func run() async throws {
    // Get simulator with `Benchmark` name, on failure create such a simulator.
    let simulatorID: String
    do {
      (simulatorID, _) = try await self.checkSimulator()
    } catch is Failure {
      simulatorID = try await self.createSimulator()
    }
    
    // Path where .xcresult file should be stored
    let resultBundlePath = Self.storage
      .directory()
      .appending(path: "\(UUID()).xcresult")
    
    try await self.test(
      schema: self.schema,
      simulatorID: simulatorID,
      resultBundlePath: resultBundlePath.path()
    )
  }
  
  func checkSimulator() async throws -> (id: String, status: String) {
    guard let (_, id, status) = try? await Subprocess.run(
        Configuration.xcrunSimctlListDevices,
        output: .string(limit: 128*128)
      )
      .standardOutput?
      .firstMatch(of: .benchmarkSimulatorUuidAndStatus)?
      .as((Substring, Substring, Substring).self)
    else { throw Failure(code: 1, errorDescription: "checkSimulatorStatus failed") }
    
    return (String(id), String(status))
  }
  
  func createSimulator(
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
    
    guard let id = result.standardOutput else {
      throw Failure(code: 2, errorDescription: "Simulator could not be created")
    }
    return id
  }
  
  func test(
    schema: String,
    simulatorID: String,
    resultBundlePath: String
  ) async throws {
    let _ = try await Subprocess.run(
      Configuration.xcodebuild(
        simulatorID: simulatorID,
        resultBundlePath: resultBundlePath
      )
    ) { _, inputIO, outputIO, errorIO in
      for try await line in outputIO.lines() {
        print(line)
      }
    }
  }
}

// MARK: - Command Configuration
extension TestCommand {
  static let storage = Storage.live
  static let cconfiguration = CommandConfiguration(
    commandName: "test"
  )
}
