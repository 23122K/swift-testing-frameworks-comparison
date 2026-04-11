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

extension URL {
  fileprivate static let xcrun = URL(filePath: "/usr/bin/xcrun")
}
