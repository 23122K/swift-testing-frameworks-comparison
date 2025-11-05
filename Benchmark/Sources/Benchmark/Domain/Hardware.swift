
// system_profiler SPHardwareDataType
extension Raport {
  public struct Hardware: Sendable, Codable {
    public let modelName: String // MacBook Pro
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

extension Raport.Hardware {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let modelName = stdout.firstMatch(of: .hardwareModelName)?.value(),
      let modelIdentifier = stdout.firstMatch(of: .hardwareModelIdentifier)?.value(),
      let modelNumber = stdout.firstMatch(of: .hardwareModelNumber)?.value(),
      let chip = stdout.firstMatch(of: .hardwareChip)?.value(),
      let totalNumberOfCores = stdout.firstMatch(of: .hardwareTotalNumberOfCores)?.value(),
      let memory = stdout.firstMatch(of: .hardwareMemory)?.value(),
      let systemFirmwareVersion = stdout.firstMatch(of: .hardwareSystemFirmwareVersion)?.value()
    else { throw Raport.Failure.stdout(stdout) }
    
    self.modelName = modelName
    self.modelIdentifier = modelIdentifier
    self.modelNumber = modelNumber
    self.chip = chip
    self.totalNumberOfCores = totalNumberOfCores
    self.memory = memory
    self.systemFirmwareVersion = systemFirmwareVersion
  }
}
