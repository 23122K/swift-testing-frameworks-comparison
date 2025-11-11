extension Report {
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
