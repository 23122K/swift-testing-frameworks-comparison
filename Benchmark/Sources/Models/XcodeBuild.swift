extension Report {
  public struct XcodeBuild: Sendable, Codable {
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
