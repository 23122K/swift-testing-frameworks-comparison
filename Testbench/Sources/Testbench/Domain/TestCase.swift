public struct TestCase: Identifiable, Sendable, Hashable, Codable {
  public let identifier: String
  public let duration: Double
  
  public var id: String {
    self.identifier
  }
}
