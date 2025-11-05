import Subprocess
import Foundation

extension Configuration {
  static let swift = Configuration(
    Executable.name("swift"),
    arguments: [
      "--version"
    ]
  )
  
  static let system = Configuration(
    Executable.name("sw_vers")
  )
  
  static let hardware = Configuration(
    Executable.name("system_profiler"),
    arguments: [
      "SPHardwareDataType"
    ]
  )
  
  static let battery = Configuration(
    Executable.name("system_profiler"),
    arguments: [
      "SPPowerDataType"
    ]
  )
  
  static let xcodebuild = Configuration(
    Executable.name("xcodebuild"),
    arguments: [
      "-version"
    ]
  )
  
  static let xcrunSimctlListDevices = Configuration(
    Executable.name("xcrun"),
    arguments: [
      "simctl",
      "list",
      "devices"
    ]
  )

  /// Creates a simulator with a given name, device type and runtime.
  ///```
  /// xcrun \
  /// simctl \
  /// create \
  /// Benchmark \
  /// com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro \
  /// com.apple.CoreSimulator.SimRuntime.iOS-26-0
  ///```
  static func xcrunSimctlCreate(
    name: String,
    device: SimDevice,
    runtime: SimRuntime
  ) -> Configuration {
    Configuration(
      Executable.name("xcrun"),
      arguments: [
        "simctl",
        "create",
        name,
        device.rawValue,
        runtime.rawValue
      ]
    )
  }
  
  /*
   xcodebuild \
   -scheme "bitchat (iOS)" \
   -destination 'platform=iOS Simulator,id=E5DACE41-AD65-473E-8FB1-65A523FD133E' \
   -resultBundlePath "/var/folders/pq/db_rwqy93bxcrth_82j0xt_00000gn/T/TestingBenchmarkRaport/0.xcresult" \
   clean test
   
   */
//   xcodebuild
//  -scheme bitchat_iOS -destination 'platform=iOS Simulator,id=E5DACE41-AD65-473E-8FB1-65A523FD133E' -  clean test
  static func xcodebuild(
    _ scheme: String = "bitchat (iOS)",
    platform: String = "iOS Simulator",
    simulatorID id: String,
    resultBundlePath path: String
  ) -> Configuration {
    Configuration(
      Executable.name("xcodebuild"),
      arguments: [
        "-scheme", scheme,
        "-destination", "platform=\(platform),id=\(id)",
        "-skipPackagePluginValidation",
        "-skipMacroValidation",
        "-resultBundlePath", path,
        "-test-iterations", "10",
        "clean",
        "test",
      ]
    )
  }
  
  
  static func convertXcresultToJson(
    at url: URL
  ) -> Configuration {
    Configuration(
      executable: "xcrun",
      arguments: {
        Arguments.ArrayLiteralElement("xcresulttool")
        Arguments.ArrayLiteralElement("get")
        Arguments.ArrayLiteralElement("test-results")
        Arguments.ArrayLiteralElement("tests")
        Arguments.ArrayLiteralElement("--path")
        Arguments.ArrayLiteralElement(url.path())
        Arguments.ArrayLiteralElement("--compact")
      }
    )
  }
  
  static func testUsingSwiftTest(
    path: String,
    filter tests: String? = nil,
    isParallel: Bool = false,
    isXctestSupported: Bool = true,
    isSwiftTestingSupported: Bool = true,
    xunit output: String?
  ) -> Configuration {
    Configuration(
      executable: "swift",
      arguments: {
        Arguments.ArrayLiteralElement("test")
      
        if let tests {
          Arguments.ArrayLiteralElement("--filter")
          Arguments.ArrayLiteralElement(tests)
        }
        
        if isParallel {
          Arguments.ArrayLiteralElement("--parallel")
        } else {
          Arguments.ArrayLiteralElement("--no-parallel")
        }
        
        if isXctestSupported {
          Arguments.ArrayLiteralElement("--enable-xctest")
        } else {
          Arguments.ArrayLiteralElement("--disable-xctest")
        }
        
        if isSwiftTestingSupported {
          Arguments.ArrayLiteralElement("--enable-swift-testing")
        } else {
          Arguments.ArrayLiteralElement("--disable-swift-testing")
        }
        
        if let output {
          Arguments.ArrayLiteralElement("--xunit-output")
          Arguments.ArrayLiteralElement(output)
        }
        
        Arguments.ArrayLiteralElement("--package-path")
        Arguments.ArrayLiteralElement(path)
      }
    )
  }
}

extension Subprocess.Configuration {
  public init(
    executable name: String,
    @ResultBuilder<String> arguments: () -> [String]
  ) {
    self.init(
      Executable.name(name),
      arguments: Arguments(
        arguments()
      )
    )
  }
}

@resultBuilder
struct ResultBuilder<T> {
  static func buildBlock(_ components: [T]...) -> [T] {
    components.flatMap(\.self)
  }
  
  static func buildExpression(_ expression: T) -> [T] {
    [expression]
  }
  
  static func buildExpression(_ expression: [T]) -> [T] {
    expression
  }

  static func buildOptional(_ components: [T]?) -> [T] {
    components ?? []
  }
  
  static func buildEither(first components: [T]) -> [T] {
    components
  }
  
  static func buildEither(second components: [T]) -> [T] {
    components
  }
}
