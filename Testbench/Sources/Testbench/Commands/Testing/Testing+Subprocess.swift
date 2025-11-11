import Subprocess

extension TestingCommand {
  func cleanSPM() async throws {
    let result = try await Subprocess.run(
      Configuration.cleanSPM,
      output: .standardOutput,
      error: .string(limit: 256*256)
    )
    
    print("Clean SPM")
    print(result.standardError ?? "Missing!")
    print(result.terminationStatus.debugDescription)
  }
  
  func test(
    path: String,
    filter tests: String?,
    isParallel: Bool,
    isXctestSupported: Bool,
    isSwiftTestingSupported: Bool,
    xunit output: String?,
    shouldSkipBuild: Bool = false
  ) async throws {
    let result = try await Subprocess.run(
      Configuration.test(
        path: path,
        filter: tests,
        isParallel: isParallel,
        isXctestSupported: isXctestSupported,
        isSwiftTestingSupported: isSwiftTestingSupported,
        xunit: output,
        shouldSkipBuild: shouldSkipBuild
      ),
      output: .standardOutput,
      error: .string(limit: 256*256)
    )
    
    print("Test command summary")
    print(result.terminationStatus.isSuccess.description)
    print(result.terminationStatus.debugDescription)
    print(result.standardError ?? "Error is missing")
  }
}

extension Configuration {
  fileprivate static let cleanSPM = Configuration(
    executable: "swift",
    arguments: {
      "package"
      "clean"
    }
  )
  
  fileprivate static func test(
    path: String,
    filter tests: String?,
    isParallel: Bool,
    isXctestSupported: Bool,
    isSwiftTestingSupported: Bool,
    xunit output: String?,
    shouldSkipBuild: Bool
  ) -> Configuration {
    Configuration(
      executable: "swift",
      arguments: {
        "test"
      
        if let tests {
          "--filter"; tests
        }
        
        if isParallel {
          "--parallel"
        } else {
          "--no-parallel"
        }
        
        if isXctestSupported {
          "--enable-xctest"
        } else {
          "--disable-xctest"
        }
        
        if isSwiftTestingSupported {
          "--enable-swift-testing"
        } else {
          "--disable-swift-testing"
        }
        
        if let output {
          "--xunit-output"; output
        }
        
        if shouldSkipBuild {
          "--skip-build"
        }
        
        "--package-path"; path
      }
    )
  }
}
