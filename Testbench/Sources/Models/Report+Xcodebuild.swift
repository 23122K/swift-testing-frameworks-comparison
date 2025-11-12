extension Report {
  public struct Xcodebuild: Sendable, Codable {
    public let version: String
    public let buildVersion: String
    
    public init(
      version: String,
      buildVersion: String
    ) {
      self.version = version
      self.buildVersion = buildVersion
    }
  }
}

extension Report.Xcodebuild: CustomStringConvertible {
  public var description: String {
    """
    Version: \(self.version)
    Build version: \(self.buildVersion)
    """
  }
}
