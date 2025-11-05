extension Raport {
  public struct Battery: Sendable, Codable {
    public let batteryPercentage: String
    public let isCharging: String
    public let isLowPowerModeOnBatteryEnabled: String
    public let isLowPowerModeOnAcEnabled: String
    
    public init(
      batteryPercentage: String,
      isCharging: String,
      isLowPowerModeOnBatteryEnabled: String,
      isLowPowerModeOnAcEnabled: String
    ) {
      self.batteryPercentage = batteryPercentage
      self.isCharging = isCharging
      self.isLowPowerModeOnBatteryEnabled = isLowPowerModeOnBatteryEnabled
      self.isLowPowerModeOnAcEnabled = isLowPowerModeOnAcEnabled
    }
  }
}

extension Raport.Battery {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let batteryPercentage = stdout.firstMatch(of: .batteryStateOfCharge)?.value(),
      let isCharging = stdout.firstMatch(of: .batteryCharging)?.value(),
      let isLowPowerModeOnBatteryEnabled = stdout.firstMatch(of: .batteryBatteryPowerLowPowerMode)?.value(),
      let isLowPowerModeOnAcEnabled = stdout.firstMatch(of: .batteryAcPowerLowPowerMode)?.value()
    else { throw Raport.Failure.stdout(stdout) }
    
    self.batteryPercentage = batteryPercentage
    self.isCharging = isCharging
    self.isLowPowerModeOnBatteryEnabled = isLowPowerModeOnBatteryEnabled
    self.isLowPowerModeOnAcEnabled = isLowPowerModeOnAcEnabled
  }
}

