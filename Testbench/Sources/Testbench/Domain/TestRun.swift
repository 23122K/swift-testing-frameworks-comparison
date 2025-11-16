public struct TestRun<XCTestOptions: Sendable, TestingOptions: Sendable> {
  public let framework: TestFramework<XCTestOptions, TestingOptions>
  public var testCases: [TestCase]
  
  public init(
    framework: TestFramework<XCTestOptions, TestingOptions>,
    testCases: [TestCase] = []
  ) {
    self.framework = framework
    self.testCases = testCases
  }
}

extension TestRun {
  public var description: String {
    """
    Framework: \(String(describing: self.framework))
    Test cases:
    \(self._testCasesDescription)
    """
  }
  
  private var _testCasesDescription: String {
    self.testCases.map {
      "\tIdentifier: \($0.identifier), duration: \($0.duration)"
    }.joined(separator: "\n")
  }
}

extension TestRun {
  public var testCount: Int {
    self.testCases.count
  }
  
  public var totalTestDuration: Double {
    self.testCases.reduce(into: 0.0) {
      $0 += $1.duration
    }
  }
}
