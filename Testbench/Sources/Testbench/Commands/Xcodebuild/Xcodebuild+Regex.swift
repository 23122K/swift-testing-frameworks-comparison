import Foundation

extension RegexComponent where Self == AnyRegex {
  static var xctestTestSuitStarted: Self {
    AnyRegex(/Test\s(s|S)uite.+started/)
  }
  
  static var xctestTestSuitPassed: Self {
    AnyRegex(/Test\sSuite\s'All\stests'\spassed\sat/)
  }
  
  static var xctestSucceeded: Self {
    AnyRegex(/TEST EXECUTE SUCCEEDED/)
  }
  
  /// Captures test name and its duration from stdout of xctest.
  static var xctestTestCaseSuccess: Self {
    AnyRegex(/\[(.+)\].+passed.+\((.+)\sseconds\)/)
  }
  
  static var testingTestRunStarted: Self {
    AnyRegex(/.+Test\srun\sstarted.+/)
  }
  
  /// Captures test run information for Testing framework.
  ///
  /// Output takes format `Test run with 1 test in 1 suite passed after 0.028 seconds.`
  /// Captures three groups:
  /// - First, number of test - `Int`
  /// - Second, number of suites - `Int`
  /// - Third, duration of the tests within suite - `Double`
  static var testingTestRunPassed: Self {
    AnyRegex(/Test\srun\swith\s([\d]+).+([\d]).+passed\safter\s([\d.]+)\sseconds/)
  }
  
  static var testingTestCaseSuccess: Self {
    AnyRegex(/Test\s(.+)\spassed\safter\s([\d.]+)/)
  }
  
  static var testingTestSuite: Self {
    AnyRegex(/Suite\s(.+)\spassed\safter\s([\d.]+)\sseconds/)
  }

  /// Captures wall-clock total time from the final XCTest summary line.
  ///
  /// Output format: `\t Executed N tests, with 0 failures (0 unexpected) in X.XXX (Y.YYY) seconds`
  /// Captures Y.YYY — the wall-clock time shown in parentheses.
  static var xctestTotalTime: Self {
    AnyRegex(/Executed\s+\d+.+in\s+[\d.]+\s+\(([\d.]+)\)\s+seconds/)
  }
}

extension Optional where Wrapped == Regex<AnyRegexOutput>.Match {
  func testCase() -> TestCase? {
    guard
      let output = self?.output,
      let (_, identifier, duration) = output.extractValues(as: (Substring, Substring, Substring).self),
      let duration = Double(duration)
    else { return nil }
    return TestCase(
      identifier: String(identifier),
      duration: duration
    )
  }
}
