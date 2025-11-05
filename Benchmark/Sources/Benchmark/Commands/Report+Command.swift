import ArgumentParser
import Subprocess
import Models
import Storage

struct ReportCommand: AsyncParsableCommand {
  @Flag(
    name: [
      .customShort("p"),
      .customLong("print")
    ],
    help: "Prints captured summary report to the consolse"
  )
  var shouldPrintSummary: Bool = false
  
  @Flag(
    name: [
      .customShort("g"),
      .customLong("generate")
    ],
    help: """
      Generates report consisting of infomation regarding:
        - Hardware
        - Battert (if applicable)
        - System
        - Swift 
        - Xcodebuild
      
      Overrides original report when run again.
      """
  )
  var shouldGenerateReport: Bool = false
  
  mutating func run() async throws {
    if self.shouldGenerateReport {
      try await self.generate()
    }
    
    if self.shouldPrintSummary {
      try self.summary()
    }
  }
  
  func generate() async throws {
    try await withThrowingTaskGroup(of: Report.self) { group in
      group.addTask {
        try await Subprocess.run(
          Configuration.swift,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Report.Swift.init(stdout:))
        .map { Report.swift($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.xcodebuild,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Report.XcodeBuild.init(stdout:))
        .map { Report.xcodebuild($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.battery,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Report.Battery.init(stdout:))
        .map { Report.battery($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.system,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Report.System.init(stdout:))
        .map { Report.system($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.hardware,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Report.Hardware.init(stdout:))
        .map { Report.hardware($0) }!
      }
      
      for try await raport in group {
        switch raport {
          case let .battery(summary):
            try Self.storage.write(summary, name: "battery.json")
            
          case let .swift(summary):
            try Self.storage.write(summary, name: "swift.json")
            
          case let .hardware(summary):
            try Self.storage.write(summary, name: "hardware.json")
            
          case let .system(summary):
            try Self.storage.write(summary, name: "system.json")
            
          case let .xcodebuild(summary):
            try Self.storage.write(summary, name: "xcodebuild.json")
        }
      }
    }
  }
  
  func summary() throws {
    let summary = try String(
      describing: Report.Summary(
        system: Self.storage.decode(name: "system.json"),
        swift: Self.storage.decode(name: "swift.json"),
        hardware: Self.storage.decode(name: "hardware.json"),
        battery: Self.storage.decode(name: "battery.json"),
        xcodebuild: Self.storage.decode(name: "xcodebuild.json")
      )
    )
    print(summary)
  }
}

// MARK: - Command Configuration
extension ReportCommand {
  static let storage = Storage.live
  static let configuration = CommandConfiguration(
    commandName: "report"
  )
}
