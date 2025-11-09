import Models

public struct TestsSummary: Sendable, Codable {
  public let testPlan: String
  public let tests: [Test]
  
  public var totalTestsDuration: Double {
    self.tests.reduce(into: 0.0) {
      $0 += $1.duration
    }
  }
}

extension TestsSummary {
  public enum Framework: Sendable, Codable {
    case xctest
    case testing
  }
  
  public struct Test: Sendable, Codable {
    let name: String
    let duration: Double
  }
}

extension Report {
  public struct TestSummary {
    public let testPlan: String
    public let framework: Framework
  }
}

extension Report {
  public enum Framework: Sendable, Codable {
    case xctest
    case testing
  }
}
