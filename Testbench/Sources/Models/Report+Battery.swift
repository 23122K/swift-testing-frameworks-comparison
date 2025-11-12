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

extension Report.Battery: CustomStringConvertible {
  public var description: String {
    """
    Battery percentage: \(self.batteryPercentage)
    Charging: \(self.isCharging)
    Low power mode (Battery): \(self.isLowPowerModeOnBatteryEnabled)
    Low power mode (AC): \(self.isLowPowerModeOnAcEnabled)
    """
  }
}
