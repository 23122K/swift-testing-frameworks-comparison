
extension Report {
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
