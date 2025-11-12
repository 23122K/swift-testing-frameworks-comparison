extension Report {
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

extension Report.System: CustomStringConvertible {
  public var description: String {
    """
    Product name: \(self.productName)
    Product version: \(self.productVersion)
    Build version: \(self.buildVersion)
    """
  }
}
