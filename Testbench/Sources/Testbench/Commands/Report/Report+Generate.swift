import Foundation
import Subprocess
import StorageClient
import Models
import Factory

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
      let stdout = (try? await Subprocess.run(
        Configuration.xcodebuild,
        output: .string(limit: 128*128)
      ).standardOutput) ?? nil
      return .xcodebuild(Report.Xcodebuild(stdout: stdout))
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

func generateReportSequentially() async throws {
  let loader = ReportLoader()
  @Injected(\.storage) var storage

  do {
    try await runReportStep(
      named: "hardware.json",
      configuration: .hardware,
      loader: loader
    ) { stdout in
      .hardware(try Report.Hardware(stdout: stdout))
    }

    try await runBatteryReportStep(
      named: "battery.json",
      loader: loader
    )

    try await runReportStep(
      named: "system.json",
      configuration: .system,
      loader: loader
    ) { stdout in
      .system(try Report.System(stdout: stdout))
    }

    try await runReportStep(
      named: "swift.json",
      configuration: .swift,
      loader: loader
    ) { stdout in
      .swift(try Report.Swift(stdout: stdout))
    }

    await runOptionalReportStep(
      named: "xcodebuild.json",
      configuration: .xcodebuild,
      loader: loader
    ) { stdout in
      .xcodebuild(Report.Xcodebuild(stdout: stdout))
    }
  } catch {
    await loader.finishOutput()
    throw error
  }

  await loader.finishOutput()
}

private func runReportStep(
  named name: String,
  configuration: Configuration,
  loader: ReportLoader,
  map: (String?) throws -> Report
) async throws {
  await loader.start(step: name)
  let tickTask = Task<Void, Never> {
    while !Task.isCancelled {
      do {
        try await Task.sleep(for: .milliseconds(100))
      } catch is CancellationError {
        break
      } catch {
        break
      }

      if Task.isCancelled {
        break
      }

      await loader.tick()
    }
  }

  do {
    let stdout = try await Subprocess.run(
      configuration,
      output: .string(limit: 128 * 128)
    ).standardOutput

    tickTask.cancel()
    await tickTask.value

    let report = try map(stdout)
    try writeReport(report)
    await loader.complete(step: name)
  } catch {
    tickTask.cancel()
    await tickTask.value
    throw error
  }
}

private func runBatteryReportStep(
  named name: String,
  loader: ReportLoader
) async throws {
  await loader.start(step: name)
  let tickTask = Task<Void, Never> {
    while !Task.isCancelled {
      do {
        try await Task.sleep(for: .milliseconds(100))
      } catch is CancellationError {
        break
      } catch {
        break
      }

      if Task.isCancelled {
        break
      }

      await loader.tick()
    }
  }

  do {
    let report = try await loadBatteryReport()

    tickTask.cancel()
    await tickTask.value

    try writeReport(.battery(report))
    await loader.complete(step: name)
  } catch {
    tickTask.cancel()
    await tickTask.value
    throw error
  }
}

private func runOptionalReportStep(
  named name: String,
  configuration: Configuration,
  loader: ReportLoader,
  map: (String?) -> Report
) async {
  do {
    try await runReportStep(named: name, configuration: configuration, loader: loader, map: map)
  } catch {
    try? writeReport(map(nil))
    await loader.complete(step: name)
  }
}

func loadBatteryReport() async throws -> Report.Battery {
  async let batteryStdout = Subprocess.run(
    Configuration.battery,
    output: .string(limit: 128 * 128)
  ).standardOutput

  async let powerSettingsStdout = Subprocess.run(
    Configuration.batteryPowerSettings,
    output: .string(limit: 128 * 128)
  ).standardOutput

  return try await Report.Battery(
    batteryStdout: batteryStdout,
    powerSettingsStdout: powerSettingsStdout
  )
}

private func writeReport(_ report: Report) throws {
  @Injected(\.storage) var storage
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

private actor ReportLoader {
  private enum ANSI {
    static let bold = "\u{001B}[1m"
    static let green = "\u{001B}[32m"
    static let reset = "\u{001B}[0m"
  }

  private let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  private var frameIndex = 0
  private var previousLineCount = 0
  private var currentStep: String?
  private var completedSteps: [String] = []

  func start(step: String) {
    currentStep = step
    redraw()
  }

  func tick() {
    guard currentStep != nil else { return }
    frameIndex += 1
    redraw()
  }

  func complete(step: String) {
    currentStep = nil
    completedSteps.append(step)
    redraw()
  }

  func finishOutput() {
    guard previousLineCount > 0 else { return }
    write("\n")
    previousLineCount = 0
  }

  private func redraw() {
    clearPreviousLines()

    var lines = ["\(ANSI.bold)Report\(ANSI.reset)"]
    for step in completedSteps {
      lines.append("  \(ANSI.green)✓\(ANSI.reset) \(step)")
    }
    if let currentStep {
      let spinner = frames[frameIndex % frames.count]
      lines.append("  \(spinner) \(currentStep)")
    }

    write(lines.joined(separator: "\n"))
    previousLineCount = lines.count
  }

  private func clearPreviousLines() {
    guard previousLineCount > 0 else { return }
    write("\r\u{1B}[2K")
    for _ in 1..<previousLineCount {
      write("\u{1B}[A\r\u{1B}[2K")
    }
  }

  private func write(_ string: String) {
    FileHandle.standardOutput.write(Data(string.utf8))
  }
}
