import Foundation
@preconcurrency import XMLCoder

public struct Xunit: Sendable, Codable, Hashable {
  public let testSuites: [TestSuite]
  
  public init(testSuites: [TestSuite]) {
    self.testSuites = testSuites
  }
}

extension Xunit {
  public struct TestSuite: Sendable, Codable, Hashable {
    public let name: String
    public let errors: Int
    public let tests: Int
    public let failures: Int
    public let skipped: Int
    public let time: Double
    public let testCases: [TestCase]
    
    public init(
      name: String,
      errors: Int,
      tests: Int,
      failures: Int,
      skipped: Int,
      time: Double,
      testCases: [TestCase]
    ) {
      self.name = name
      self.errors = errors
      self.tests = tests
      self.failures = failures
      self.skipped = skipped
      self.time = time
      self.testCases = testCases
    }
  }
}

extension Xunit {
  public struct TestCase: Sendable, Codable, Hashable {
    public let className: String
    public let name: String
    public let time: Double
    
    public init(
      className: String,
      name: String,
      time: Double
    ) {
      self.className = className
      self.name = name
      self.time = time
    }
  }
}

extension Xunit: DynamicNodeDecoding {
  private enum CodingKeys: String, CodingKey {
    case testSuites = "testsuite"
  }
  
  public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
    .element
  }
}

extension Xunit.TestSuite: DynamicNodeDecoding {
  private enum CodingKeys: String, CodingKey {
    case name
    case errors
    case tests
    case failures
    case skipped
    case time
    case testCases = "testcase"
  }

  public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
    switch key {
      case CodingKeys.name,
        CodingKeys.errors,
        CodingKeys.tests,
        CodingKeys.failures,
        CodingKeys.skipped,
        CodingKeys.time:
        return .attribute
        
      default:
        return .element
    }
  }
}

extension Xunit.TestCase: DynamicNodeDecoding {
  private enum CodingKeys: String, CodingKey {
    case className = "classname"
    case name
    case time
  }

  public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
    .attribute
  }
}
