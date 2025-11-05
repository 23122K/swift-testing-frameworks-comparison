extension Report {
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
