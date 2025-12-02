extension Report {
  public struct System: Sendable, Codable {
    public let productName: String
    public let productVersion: String
    public let buildVersion: String
    
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
