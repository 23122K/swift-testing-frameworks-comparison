struct XCTestOptions: Sendable, Encodable {
  let testPlan: String
  let regex: AnyRegex
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.testPlan)
  }
}

struct TestingOptions: Sendable {
  let testPlan: String
  let regex: AnyRegex
  let ignoreRegexes: [AnyRegex]
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.testPlan)
  }
}

struct TestSummary: Sendable, Codable {
  let testPlan: String
  let framework: String
  let testCases: [TestCase]
}

typealias XcodebuildTestRun = TestRun<XCTestOptions, TestingOptions>
extension XcodebuildTestRun {
  var testPlan: String {
    switch self.framework {
      case let .xctest(options):
        options.testPlan
        
      case let .swiftTesting(options):
        options.testPlan
    }
  }
  
  var summary: TestSummary {
    TestSummary(
      testPlan: self.testPlan,
      framework: self.framework.description,
      testCases: self.testCases
    )
  }
}
