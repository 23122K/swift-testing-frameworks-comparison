import Foundation
import Subprocess
import StorageClient
import Models

extension XCTestCommand {
  /// Runs each `(scheme, bundle)` pair `iterations` times, saving per-iteration JSON results.
  func runAllBundles(_ bundles: [(scheme: String, bundle: URL)]) async throws {
    for (scheme, bundle) in bundles {
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
        try self.saveSummary(summary, scheme: scheme, targetName: targetName, iteration: iteration)

        print("[\(scheme) / \(bundleName) / \(frameworkName)] Iteration \(iteration)/\(self.iterations): \(String(format: "%.3f", runtime))s")
      }
    }
  }

  /// Runs a single `.xctest` bundle via `xcrun xctest` and returns all stderr lines.
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
    let testingRegex: AnyRegex = .testingTestRunPassed
    for line in lines.reversed() {
      if let match = line.firstMatch(of: testingRegex.regex),
         let (_, _, _, durationStr) = match.output.extractValues(as: (Substring, Substring, Substring, Substring).self),
         let duration = Double(durationStr) {
        return duration
      }
    }
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

  /// Saves a `TestSummary` to `<storage>/xcodebuild/<scheme>/<targetName>/iteration-<N>.json`.
  private func saveSummary(_ summary: TestSummary, scheme: String, targetName: String, iteration: Int) throws {
    let dir = self.storage
      .directory()
      .appending(path: "xcodebuild")
      .appending(path: scheme)
      .appending(path: targetName)

    try self.storage.createDirectory(dir)

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    try self.storage.writeData(encoder.encode(summary), dir.appending(path: "iteration-\(iteration).json"))
  }
}
