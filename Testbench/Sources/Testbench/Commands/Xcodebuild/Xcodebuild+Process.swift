import Foundation
import Subprocess

extension XcodebuildCommand {
  func xcodebuildBuildForTesting(
    scheme: String,
    destination: String = "platform=macOS,arch=arm64,name=My Mac",
    derivedData: URL
  ) async throws -> URL {
    let result = try await Subprocess.run(
      Configuration(
        executable: "xcrun",
        arguments: {
          "xcodebuild"
          "build-for-testing"
          "-scheme"; scheme
          "-destination"; "\(destination)"
          "-derivedDataPath"; "\(derivedData.path())"
        }
      )
    ) { _, _, stdout, stderr in
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

    return derivedData
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

extension URL {
  fileprivate static let xcrun = URL(filePath: "/usr/bin/xcrun")
}
