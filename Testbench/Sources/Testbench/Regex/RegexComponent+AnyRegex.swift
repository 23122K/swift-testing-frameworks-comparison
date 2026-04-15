import Foundation

extension RegexComponent where Self == AnyRegex {
  // MARK: - Swift
  static var swiftVersionPattern: Self {
    AnyRegex(/Apple Swift version\s*([^\s]+)/)
  }
  
  static var swiftTargetPattern: Self {
    AnyRegex(/Target:\s*([^\s]+)/)
  }
  
  // MARK: - System
  static var systemBuildVersion: Self {
    AnyRegex(/BuildVersion:\t\t([ a-zA-Z0-9]+)/)
  }
  
  static var systemProductName: Self {
    AnyRegex(/ProductName:\t\t([ a-zA-Z]+)/)
  }
  
  static var systemProductVersion: Self {
    AnyRegex(/ProductVersion:\t\t([ 0-9.]+)/)
  }
  
  // MARK: Hardware
  static var hardwareModelName: Self {
    AnyRegex(/Model Name:\s*([ a-zA-Z0-9]+)/)
  }
  
  static var hardwareModelIdentifier: Self {
    AnyRegex(/Model Identifier:\s*([ a-zA-Z0-9,.]+)/)
  }
  
  static var hardwareModelNumber: Self {
    AnyRegex(/Model Number:\s*([ a-zA-Z0-9]+)/)
  }
  
  static var hardwareChip: Self {
    AnyRegex(/Chip:\s*([ a-zA-Z0-9]+)/)
  }
  
  static var hardwareTotalNumberOfCores: Self {
    AnyRegex(/Total Number of Cores:\s*([ a-zA-Z0-9()]+)/)
  }
  
  static var hardwareMemory: Self {
    AnyRegex(/Memory:\s*([ a-zA-Z0-9]+)/)
  }
  
  static var hardwareSystemFirmwareVersion: Self {
    AnyRegex(/System Firmware Version:\s*([ 0-9.]+)/)
  }
  
  // MARK: - Battery
  static var batteryStateOfCharge: Self {
    AnyRegex(/State of Charge \(\%\):\s*(\d+)/)
  }

  static var batteryStateOfChargePmset: Self {
    AnyRegex(/(\d+)%/)
  }
  
  static var batteryCharging: Self {
    AnyRegex(/Charging:\s*(\w+)/)
  }

  static var batteryChargingPmset: Self {
    AnyRegex(/;\s*([A-Za-z ]+?)\s*;/)
  }
  
  static var batteryAcPowerLowPowerMode: Self {
    AnyRegex(/(?s)AC Power:.*?Low Power Mode:\s*(Yes|No)/)
  }

  static var batteryAcPowerLowPowerModePmset: Self {
    AnyRegex(/(?s)AC Power:.*?lowpowermode\s+([01])/)
  }
  
  static var batteryBatteryPowerLowPowerMode: Self {
    AnyRegex(/(?s)Battery Power:.*?Low Power Mode:\s*(Yes|No)/)
  }

  static var batteryBatteryPowerLowPowerModePmset: Self {
    AnyRegex(/(?s)Battery Power:.*?lowpowermode\s+([01])/)
  }
  
  // MARK: - XcodeBuikd
  static var xcodeVersion: Self {
    AnyRegex(/Xcode\s([0-9.]+)/)
  }
  
  /// Captures test name and its duration from stdout of xctest.
  static var xctest: Self {
    AnyRegex(/\[(.+)\].+passed.+\((.+)\sseconds\)/)
  }
  
  static var testing: Self {
    AnyRegex(/Test\s(.+)\spassed\safter\s([\d.]+)/)
  }
  
  static var xcodeBuildVersion: Self {
    AnyRegex(/Build\sversion\s(\w+)/)
  }
  
  // MARK: SimDevice
  
  static var benchmarkSimulatorUuidAndStatus: Self {
    AnyRegex(/Benchmark\s\(([A-Z0-9-]+)\)\s\((\w+)\)/)
  }
}

