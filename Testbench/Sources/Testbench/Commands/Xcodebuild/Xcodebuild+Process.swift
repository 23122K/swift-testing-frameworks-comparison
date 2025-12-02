import Foundation

extension XcodebuildCommand {
  func getXcodePath() async throws -> URL {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
    process.arguments = arguments {
      "--print-path"
    }
    
    let standardOutput = Pipe()
    process.standardOutput = standardOutput
    try process.run()
    
    guard
      let filePath = try await standardOutput.fileHandleForReading.bytes.lines.first(where: { _ in true })
    else { fatalError("WIP") }
    
    return URL(filePath: filePath)
  }
  
  func invokeXcodebuild(
    scheme: String,
    destination: String = "platform=macOS,arch=arm64,name=My Mac",
    derrivedDataPath: String? = nil,
    resultBundlePath: String? = nil,
    testPlan: String,
    shouldSkipPackagePluginValidation: Bool = true,
    shouldSkipMacroValidation: Bool = true,
    isParallelTestingEnabled: Bool = false,
    parallelTestingWorkerCount: Int = 1,
    _ output: @escaping (String) -> Void
  ) async throws {
    let process = Process()
    let standardOutput = Pipe()
    process.standardOutput = standardOutput
    process.executableURL = try await self.getXcodePath()
      .appending(path: "usr")
      .appending(path: "bin")
      .appending(path: "xcodebuild")
    
    process.arguments = arguments {
      "test"
      "-scheme"; self.schema
      "-destination"; "platform=macOS,arch=arm64,name=My Mac"
      if let derrivedDataPath {
        "-derivedDataPath"; "\(derrivedDataPath)"
      }
      
      if let resultBundlePath {
        "-resultBundlePath"; "\(resultBundlePath)"
      }
      "-testPlan"; "\(testPlan)"
      if shouldSkipPackagePluginValidation {
        "-skipPackagePluginValidation"
      }
      if shouldSkipMacroValidation {
        "-skipMacroValidation"
      }
      "-parallel-testing-enabled"; isParallelTestingEnabled ? "YES" : "NO"
      "-parallel-testing-worker-count"; "\(parallelTestingWorkerCount)"
    }
    
    try process.run()
    for try await line in standardOutput.fileHandleForReading.bytes.lines {
      output(line)
    }
  }
}
