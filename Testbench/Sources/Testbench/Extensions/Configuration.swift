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
   -resultBundlePath "/var/folders/pq/db_rwqy93bxcrth_82j0xt_00000gn/T/TestingBenchmarkReport/0.xcresult" \
   clean test
   
   */
//   xcodebuild
//  -scheme bitchat_iOS -destination 'platform=iOS Simulator,id=E5DACE41-AD65-473E-8FB1-65A523FD133E' -  clean tes
  
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
