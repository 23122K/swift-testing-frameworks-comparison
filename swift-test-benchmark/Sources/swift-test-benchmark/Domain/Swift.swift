extension Raport {
  public struct Swift: Sendable, Codable {
    public let version: String
    public let target: String
      
    public init(
      version: String,
      target: String
    ) {
      self.version = version
      self.target = target
    }
  }
}

extension Raport.Swift {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let version = stdout.firstMatch(of: .swiftVersionPattern)?.value(),
      let target = stdout.firstMatch(of: .swiftTargetPattern)?.value()
    else { throw Raport.Failure.stdout(stdout) }
    
    self.version = version
    self.target = target
  }
}
