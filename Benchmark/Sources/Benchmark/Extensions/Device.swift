/// Represents SimDeviceType
public enum SimDevice: String, Sendable {
  case iPhone17Pro = "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro"
  case iPhone17ProMax = "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max"
  case iPhoneAir = "com.apple.CoreSimulator.SimDeviceType.iPhone-Air"
  case iPhone17 = "com.apple.CoreSimulator.SimDeviceType.iPhone-17"
  
  struct Status: Sendable {
    var active: String
    var uuid: String
  }
}

/// Represetns SimRuntime
/// `xcrun simctl list runtimes`
public enum SimRuntime: String, Sendable {
  case iOS26_0 = "com.apple.CoreSimulator.SimRuntime.iOS-26-0"
}
