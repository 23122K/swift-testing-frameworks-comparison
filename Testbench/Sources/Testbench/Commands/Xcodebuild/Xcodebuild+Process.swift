import Foundation
import Subprocess

extension XcodebuildCommand {
  func xcodebuildBuildForTesting(
    scheme: String,
    destination: String = "platform=macOS,arch=arm64,name=My Mac",
    derrivedData: URL,
    shouldSkipPackagePluginValidation: Bool = true,
    shouldSkipMacroValidation: Bool = true,
    isParallelTestingEnabled: Bool = false,
    parallelTestingWorkerCount: Int = 1
  ) async throws -> URL {
    let result = try await Subprocess.run(
      Configuration(
        executable: "xcrun",
        arguments: {
          "xcodebuild"
          "clean"
          "build-for-testing"
          "-scheme"; self.schema
          "-configuration"; "Debug"
          "-destination"; "\(destination)"
          "-derivedDataPath"; "\(derrivedData.path())"
          if shouldSkipPackagePluginValidation {
            "-skipPackagePluginValidation"
          }
          if shouldSkipMacroValidation {
            "-skipMacroValidation"
          }
          "-parallel-testing-enabled"; isParallelTestingEnabled ? "YES" : "NO"
          "-parallel-testing-worker-count"; "\(parallelTestingWorkerCount)"
        }
      )
    ) { _, _, stdout, stderr -> Void in
      // Stream both stdout and stderr so build errors are visible.
      try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask {
          for try await line in stdout.lines() { print(line) }
        }
        group.addTask {
          for try await line in stderr.lines() { print(line) }
        }
        try await group.waitForAll()
      }
    }

    guard result.terminationStatus.isSuccess else {
      throw XcodebuildError.buildFailed(scheme: scheme, status: result.terminationStatus)
    }

    return derrivedData
      .appending(path: "Build")
      .appending(path: "Products")
      .appending(path: "Debug")
  }
}

enum XcodebuildError: Error, CustomStringConvertible {
  case buildFailed(scheme: String, status: TerminationStatus)

  var description: String {
    switch self {
    case let .buildFailed(scheme, status):
      return "xcodebuild build-for-testing failed for scheme '\(scheme)' (exit: \(status))"
    }
  }
}

extension XcodebuildCommand {
  /// Runs a single `.xctest` bundle via `xcrun xctest` and returns all stderr lines.
  ///
  /// Both XCTest and Swift Testing write their framework output to stderr.
  /// Stdout (application print statements) is discarded to prevent pipe blockage.
  func xcrunXCTest(bundle: URL) async throws -> [String] {
    let result = try await Subprocess.run(
      Configuration(
        executable: "xcrun",
        arguments: {
          "xctest"
          bundle.path()
        }
      ),
      output: .discarded
    ) { _, _, stderr -> [String] in
      var lines: [String] = []
      for try await line in stderr.lines() {
        lines.append(line)
      }
      return lines
    }
    return result.value
  }

  /// Runs each bundle `iterations` times, extracting and saving per-iteration results to JSON.
  /// Prints the total runtime after every run.
  func runXCTestBundles(_ bundles: [URL]) async throws {
    for bundle in bundles {
      let bundleName = bundle.lastPathComponent
      let targetName = bundle.deletingPathExtension().lastPathComponent
      var isSwiftTesting = false

      for iteration in 1...self.iterations {
        let lines = try await self.xcrunXCTest(bundle: bundle)
        if iteration == 1 {
          isSwiftTesting = self.isSwiftTestingBundle(lines)
        }
        let frameworkName = isSwiftTesting ? "Swift Testing" : "XCTest"
        let runtime = self.extractRuntime(from: lines)
        let testCases = self.extractTestCases(from: lines, isSwiftTesting: isSwiftTesting)

        let summary = TestSummary(
          testPlan: targetName,
          framework: frameworkName,
          testRunDuration: runtime,
          testCases: testCases
        )
        try self.saveSummary(summary, targetName: targetName, iteration: iteration)

        print("[\(bundleName) / \(frameworkName)] Iteration \(iteration)/\(self.iterations): \(String(format: "%.3f", runtime))s")
      }
    }
  }

  // MARK: - Framework detection

  private func isSwiftTestingBundle(_ lines: [String]) -> Bool {
    let regex: AnyRegex = .testingTestRunPassed
    return lines.contains { $0.firstMatch(of: regex.regex) != nil }
  }

  // MARK: - Test case extraction

  private func extractTestCases(from lines: [String], isSwiftTesting: Bool) -> [TestCase] {
    if isSwiftTesting {
      let caseRegex: AnyRegex = .testingTestCaseSuccess
      let runRegex: AnyRegex = .testingTestRunPassed
      return lines.compactMap { line -> TestCase? in
        // Skip the "Test run with N tests…" summary line — it also matches testingTestCaseSuccess.
        guard line.firstMatch(of: runRegex.regex) == nil else { return nil }
        return line.firstMatch(of: caseRegex.regex).testCase()
      }
    } else {
      let caseRegex: AnyRegex = .xctestTestCaseSuccess
      return lines.compactMap { line in
        line.firstMatch(of: caseRegex.regex).testCase()
      }
    }
  }

  // MARK: - Total runtime extraction

  private func extractRuntime(from lines: [String]) -> Double {
    // Swift Testing: "Test run with N tests in N suites passed after X.XXX seconds."
    let testingRegex: AnyRegex = .testingTestRunPassed
    for line in lines.reversed() {
      if let match = line.firstMatch(of: testingRegex.regex),
         let (_, _, _, durationStr) = match.output.extractValues(as: (Substring, Substring, Substring, Substring).self),
         let duration = Double(durationStr) {
        return duration
      }
    }
    // XCTest: take the last "Executed N tests… in X.XXX (Y.YYY) seconds" — the "All tests" total.
    let xcTestRegex: AnyRegex = .xctestTotalTime
    var lastTime: Double = 0.0
    for line in lines {
      if let match = line.firstMatch(of: xcTestRegex.regex),
         let (_, timeStr) = match.output.extractValues(as: (Substring, Substring).self),
         let time = Double(timeStr) {
        lastTime = time
      }
    }
    return lastTime
  }

  // MARK: - JSON persistence

  /// Saves a `TestSummary` to `<storage>/xcodebuild/<schema>/<targetName>/iteration-<N>.json`.
  private func saveSummary(_ summary: TestSummary, targetName: String, iteration: Int) throws {
    let dir = self.storage
      .directory()
      .appending(path: "xcodebuild")
      .appending(path: self.schema)
      .appending(path: targetName)

    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

    let fileURL = dir.appending(path: "iteration-\(iteration).json")
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try encoder.encode(summary).write(to: fileURL)
  }
}

extension URL {
  fileprivate static let xcrun = URL(filePath: "/usr/bin/xcrun")
}
