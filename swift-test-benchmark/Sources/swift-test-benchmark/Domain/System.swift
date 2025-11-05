
extension Raport {
  // sw_vers
  public struct System: Sendable, Codable {
    public let productName: String // macOS
    public let productVersion: String // 26.0.1
    public let buildVersion: String // 25A362
    
    public init(
      productName: String,
      productVersion: String,
      buildVersion: String
    ) {
      self.productName = productName
      self.productVersion = productVersion
      self.buildVersion = buildVersion
    }
  }
}

extension Raport.System {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let productName = stdout.firstMatch(of: .systemProductName)?.value(),
      let productVersion = stdout.firstMatch(of: .systemProductVersion)?.value(),
      let buildVersion = stdout.firstMatch(of: .systemBuildVersion)?.value()
    else { throw Raport.Failure.stdout(stdout) }

    self.productName = productName
    self.productVersion = productVersion
    self.buildVersion = buildVersion
  }
}
