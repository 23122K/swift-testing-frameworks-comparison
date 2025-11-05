import ArgumentParser
import Subprocess
import Foundation
import XMLCoder

struct Failure: LocalizedError, Equatable {
  let code: UInt8
  let errorDescription: String?
  
  init(
    code: UInt8,
    errorDescription: String? = nil
  ) {
    self.code = code
    self.errorDescription = errorDescription
  }
}


struct TestCommand: AsyncParsableCommand {
  static let fileManager = FileManagerClient.shared
  static let cconfiguration: CommandConfiguration = CommandConfiguration(
    commandName: "test"
  )
  
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
    let resultBundlePath = Self.fileManager
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


@main
struct Benchmark: AsyncParsableCommand {
  static let fileManager = FileManagerClient.shared
  static let configuration: CommandConfiguration = CommandConfiguration(
    commandName: "benchmark",
    subcommands: [
      RaportCommand.self,
      TestCommand.self
    ]
//    defaultSubcommand: RaportCommand.self
  )
  
  mutating func run() async throws {
    let xunitPath = Self.fileManager
      .directory()
      .appending(path: "test_me_2.xml")
    
    do {
      let xunit = try Xunit(at: xunitPath)
//      print(xunit.tests())
//      print(xunit.count())
    } catch {
      print(error)
    }
    
    let xcresultPath = Self.fileManager
      .directory()
      .appending(path: "test_me.xcresult")
    
    do {
      let url = try await Subprocess.run(
        Configuration.convertXcresultToJson(at: xcresultPath),
        output: .file(name: "nope")
      ).standardOutput
     
      let string64Data = try String(contentsOf: url, encoding: .utf8)
      print(string64Data)
//      print(status.debugDescription)
      
//      let xcresultJsonPath = Self.fileManager
//        .directory()
//        .appending(path: "nope")
      
//      let data = try FileManagerClient.shared.contents(url)
//      let string64Data = String(data: data, encoding: .ascii)
//      print(string64Data)
      
      
//      print(xcresult.testNodes.count)
    } catch {
      print(error)
    }
  }
}

public struct FileOutput: OutputProtocol {
  public typealias OutputType = URL
  public let maxSize: Int
  public let name: String
  
  public func output(from span: RawSpan) throws -> URL {
    var data = Data()
    span.withUnsafeBytes { buffer in
      if let base = buffer.baseAddress {
        data.append(base.assumingMemoryBound(to: UInt8.self), count: buffer.count)
      }
    }
    
    try FileManagerClient.shared.write(
      data,
      name: self.name
    )
    
    return FileManagerClient.shared.directory()
      .appending(path: name)
  }
  
  public func output(from buffer: some Sequence<UInt8>) throws -> OutputType {
    print("XDD?")
    let data = Data(buffer)
    print(data.count)
    try FileManagerClient.shared.write(
      "Kupa".data(using: .utf8),
      name: name
    )
    
    return FileManagerClient.shared.directory()
      .appending(path: name)
  }
}

extension OutputProtocol where Self == FileOutput {
  static func file(
    name: String,
    limit maxSize: Int = 256 * 256
  ) -> Self {
    self.init(maxSize: maxSize, name: name)
  }
}

extension String {
  func trimmed() -> String {
    let result = self
      .replacing(/\t+/, with: "")
      .replacing(/\n/, with: "")
      .replacing(/\s+/, with: " ")
    
    print(result)
    return result
  }
}
