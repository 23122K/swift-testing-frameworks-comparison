public struct TestRun<XCTestOptions: Sendable, TestingOptions: Sendable>: Sendable {
  public let framework: TestFramework<XCTestOptions, TestingOptions>
  public var testCases: [TestCase]
  public var testRunDuration: Double
  
  public init(
    framework: TestFramework<XCTestOptions, TestingOptions>,
    testCases: [TestCase] = [],
    testRunDuration: Double = 0.0
  ) {
    self.framework = framework
    self.testCases = testCases
    self.testRunDuration = testRunDuration
  }
}

extension TestRun: Equatable where XCTestOptions: Equatable, TestingOptions: Equatable {}
extension TestRun: Hashable where XCTestOptions: Hashable, TestingOptions: Hashable {}

extension TestRun {
  public var description: String {
    """
    Framework: \(String(describing: self.framework))
    Test run duration: \(self.testRunDuration) seconds
    Test cases combined duration: \(self.totalTestDuration) seconds  
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
