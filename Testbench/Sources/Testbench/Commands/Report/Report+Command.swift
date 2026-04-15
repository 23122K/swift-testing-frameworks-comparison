import ArgumentParser
import DefaultsClient
import DateClient
import Foundation
import Factory
import Subprocess
import Models
import StorageClient

struct ReportCommand: AsyncParsableCommand {
  @Flag(
    name: [
      .customShort("v"),
      .customLong("verbose")
    ],
    help: "Show verbose logging output"
  )
  var isVerbose: Bool = false
  
  @Flag(
    name: [
      .customShort("s"),
      .customLong("summary")
    ],
    help: "Show report summary"
  )
  var shoudShowSummary: Bool = false
  
  @Flag(
    name: [
      .customShort("g"),
      .customLong("generate")
    ],
    help: """
      Generate report.
      
      Report summary consists of:
        - Hardware
        - Battery (if applicable)
        - System
        - Swift 
        - Xcodebuild
      """
  )
  var shouldGenerateReport: Bool = false
  
  mutating func run() async throws {
    self.defaults.set(self.now, forKey: .lastTestbenchUsage)
    
    if self.shouldGenerateReport {
      try await self.generate()
      try print(self.summary())
      self.defaults.set(true, forKey: .isReportGenerated)
    }
    
    if self.shoudShowSummary {
      try print(self.summary())
    }
  }
  
  private func generate() async throws {
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
        .map(Report.Xcodebuild.init(stdout:))
        .map { Report.xcodebuild($0) }!
      }
      
      group.addTask {
        .battery(try await loadBatteryReport())
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
            try self.storage.write(summary, name: "battery.json")
            
          case let .swift(summary):
            try self.storage.write(summary, name: "swift.json")
            
          case let .hardware(summary):
            try self.storage.write(summary, name: "hardware.json")
            
          case let .system(summary):
            try self.storage.write(summary, name: "system.json")
            
          case let .xcodebuild(summary):
            try self.storage.write(summary, name: "xcodebuild.json")
        }
      }
    }
  }
  
  private func summary() throws -> Report.Summary {
    try Report.Summary(
      system: self.storage.decode(name: "system.json"),
      swift: self.storage.decode(name: "swift.json"),
      hardware: self.storage.decode(name: "hardware.json"),
      battery: self.storage.decode(name: "battery.json"),
      xcodebuild: self.storage.decode(name: "xcodebuild.json")
    )
  }
}

extension ReportCommand {
  fileprivate var storage: StorageClient {
    @Injected(\.storage) var storage
    return storage
  }
  
  fileprivate var defaults: DefaultsClient {
    @Injected(\.defaults) var defaults
    return defaults
  }
  
  fileprivate var now: Date {
    @Injected(\.date) var date
    return date.now()
  }
}
