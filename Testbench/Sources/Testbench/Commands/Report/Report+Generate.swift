import Foundation
import Subprocess
import StorageClient
import Models

func generateReport(storage: StorageClient) async throws {
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

    for try await report in group {
      switch report {
      case let .battery(summary):
        try storage.write(summary, name: "battery.json")
      case let .swift(summary):
        try storage.write(summary, name: "swift.json")
      case let .hardware(summary):
        try storage.write(summary, name: "hardware.json")
      case let .system(summary):
        try storage.write(summary, name: "system.json")
      case let .xcodebuild(summary):
        try storage.write(summary, name: "xcodebuild.json")
      }
    }
  }
}
