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
    derrivedDataPath: String?
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
        "clean"
        "test"
        "-quiet"
      }
    )
  }
}
