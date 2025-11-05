extension Raport {
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

extension Raport.XcodeBuild {
  public init(stdout: String?) throws {
     guard
      let stdout,
      let version = stdout.firstMatch(of: .xcodeVersion)?.value(),
      let buildVersion = stdout.firstMatch(of: .xcodeBuildVersion)?.value()
    else { throw Raport.Failure.stdout(stdout) }
    
    self.version = version
    self.buildVersion = buildVersion
  }
}
