import Subprocess

extension Configuration {
  ///
  /// ```bash
  /// xcodebuild \
  /// -scheme swift-loggable \
  /// -destination "platform=macOS,arch=arm64,name=My Mac" \
  /// -testPlan swift-loggable-xctests \
  /// -resultBundlePath ./test_me_1.xcresult \
  /// -derivedDataPath ./DerrivedData/ \
  /// clean \
  /// test \
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
        "test"
//        "-quiet"
      }
    )
  }
}
