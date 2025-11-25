import Subprocess

extension Configuration {
  ///
  /// ```bash
  /// xcodebuild \
  /// -scheme Testbench \
  /// -destination "platform=macOS,arch=arm64,name=My Mac" \
  /// -testPlan testbench-xctest \
  /// -derivedDataPath ./DerrivedData/ \
  /// -skipPackagePluginValidation \
  /// -skipMacroValidation \
  /// -maximum-concurrent-test-device-destinations 1 \
  /// -maximum-concurrent-test-simulator-destinations 1 \
  /// -parallel-testing-enabled NO \
  /// -parallel-testing-worker-count 1 \
  /// -maximum-parallel-testing-workers 1 \
  /// test
  /// ```
  ///
  static func test(
    _ scheme: String,
    testPlan: String?,
    platform: String,
    resultBundlePath: String?,
    derrivedDataPath: String?,
    isParallelTestingEnabled: Bool,
    maximumConcurrentTestDeviceDestinations: Int,
    maximumConcurrentTestSimulatorDestinations: Int,
    parallelTestingWorkerCount: Int,
    maximumParallelTestingWorkers: Int
  ) -> Configuration {
    Configuration(
      executable: "xcodebuild",
      arguments: {
        "-scheme"; scheme
        "-destination"; "platform=macOS,arch=arm64,name=My Mac"
        
        if let testPlan {
          "-testPlan"; testPlan
        }
        
        if let resultBundlePath {
          "-resultBundlePath"; resultBundlePath
        }
        
        if let derrivedDataPath {
          "-derivedDataPath"; derrivedDataPath
        }
        
        "-skipPackagePluginValidation"
        "-skipMacroValidation"
        "-maximum-concurrent-test-device-destinations"; "\(maximumConcurrentTestDeviceDestinations)"
        "-maximum-concurrent-test-simulator-destinations"; "\(maximumConcurrentTestSimulatorDestinations)"
        "-parallel-testing-enabled"; isParallelTestingEnabled ? "YES" : "NO"
        "-parallel-testing-worker-count"; "\(parallelTestingWorkerCount)"
        "-maximum-parallel-testing-workers"; "\(maximumParallelTestingWorkers)"
//        "clean"
        "test-without-building"
//        "-quiet"
      }
    )
  }
}
