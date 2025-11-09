import Subprocess

extension TestingCommand {
  func cleanSPM() async throws {
    _ = try await Subprocess.run(
      Configuration.cleanSPM,
      output: .discarded
    )
  }
  
  func test(
    path: String,
    filter tests: String?,
    isParallel: Bool,
    isXctestSupported: Bool,
    isSwiftTestingSupported: Bool,
    xunit output: String?
  ) async throws {
    _ = try await Subprocess.run(
      Configuration.test(
        path: path,
        filter: tests,
        isParallel: isParallel,
        isXctestSupported: isXctestSupported,
        isSwiftTestingSupported: isSwiftTestingSupported,
        xunit: output
      ),
      output: .discarded
    )
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
    xunit output: String?
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
        
        "--package-path"; path
      }
    )
  }
}
