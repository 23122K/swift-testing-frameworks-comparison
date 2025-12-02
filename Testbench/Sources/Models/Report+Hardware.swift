extension Report {
  public struct Hardware: Sendable, Codable {
    public let modelName: String
    public let modelIdentifier: String
    public let modelNumber: String
    public let chip: String
    public let totalNumberOfCores: String
    public let memory: String
    public let systemFirmwareVersion: String
    
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
