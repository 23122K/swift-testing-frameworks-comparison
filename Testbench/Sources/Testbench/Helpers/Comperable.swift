import Foundation
import Models

public struct TestsSummary: Sendable, Codable {
  public let author: String
  public let date: Date
  
  public let testPlan: String
  public let testCases: [TestCase]
  
  public var totalTestsDuration: Double {
    self.testCases.reduce(into: 0.0) {
      $0 += $1.duration
    }
  }
}

extension TestsSummary {
  public struct TestCase: Sendable, Codable {
    let name: String
    let duration: Double
  }
}

extension Report {
  public struct TestSummary {
    public let testPlan: String
  }
}
