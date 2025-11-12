/// `system_profiler SPHardwareDataType`
extension Report {
  public struct Hardware: Sendable, Codable {
    public let modelName: String
    public let modelIdentifier: String // MacBookPro17,1
    public let modelNumber: String // Z11B0002QZE/A
    public let chip: String //Apple M1
    public let totalNumberOfCores: String // 8 (4 performance and 4 efficiency)
    public let memory: String //16 GB
    public let systemFirmwareVersion: String // 13822.1.2
    
    public init(
      modelName: String,
      modelIdentifier: String,
      modelNumber: String,
      chip: String,
      totalNumberOfCores: String,
      memory: String,
      systemFirmwareVersion: String
    ) {
      self.modelName = modelName
      self.modelIdentifier = modelIdentifier
      self.modelNumber = modelNumber
      self.chip = chip
      self.totalNumberOfCores = totalNumberOfCores
      self.memory = memory
      self.systemFirmwareVersion = systemFirmwareVersion
    }
  }
}

extension Report.Hardware: CustomStringConvertible {
  public var description: String {
    """
    Model name: \(self.modelName)
    Model identifier:\(self.modelIdentifier)
    Model number: \(self.modelNumber)
    Chip: \(self.chip)
    Total number of cores: \(self.totalNumberOfCores)
    Memory: \(self.memory)
    System firmware version: \(self.systemFirmwareVersion)
    """
  }
}
