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
    _ = try await Subprocess.run(
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
    ) { _, _, lines, _ in
//      for try await line in lines {
//        print(line)
//      }
    }
    
    return derrivedData
      .appending(path: "Build")
      .appending(path: "Products")
      .appending(path: "Debug")
  }
}

extension XcodebuildCommand {
  /// Runs a single `.xctest` bundle via `xcrun xctest` and returns all stderr lines.
  ///
  /// XCTest and Swift Testing both write their output to stderr.
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

  /// Runs each bundle `iterations` times, printing the total runtime after each run.
  func runXCTestBundles(_ bundles: [URL]) async throws {
    for bundle in bundles {
      let bundleName = bundle.lastPathComponent
      var frameworkName = ""

      for iteration in 1...self.iterations {
        let lines = try await self.xcrunXCTest(bundle: bundle)
        if iteration == 1 {
          frameworkName = self.detectFrameworkName(from: lines)
        }
        let runtime = self.extractRuntime(from: lines)
        print("[\(bundleName) / \(frameworkName)] Iteration \(iteration)/\(self.iterations): \(String(format: "%.3f", runtime))s")
      }
    }
  }

  private func detectFrameworkName(from lines: [String]) -> String {
    let regex: AnyRegex = .testingTestRunPassed
    let isSwiftTesting = lines.contains { $0.firstMatch(of: regex.regex) != nil }
    return isSwiftTesting ? "Swift Testing" : "XCTest"
  }

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
    // XCTest: take the last "Executed N tests... in X.XXX (Y.YYY) seconds" — that's the "All tests" total.
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
}

extension URL {
  fileprivate static let xcrun = URL(filePath: "/usr/bin/xcrun")
}
