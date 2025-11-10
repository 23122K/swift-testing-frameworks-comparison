import Foundation
import Models

extension Xunit {
  public var summary: TestsSummary {
    TestsSummary(
      testPlan: "Testing",
      tests: self.testSuites.reduce(into: []) { result, testSuite in
        result.append(contentsOf:
          testSuite.testCases.map { testCase in
            TestsSummary.Test(
              name: testCase.name,
              duration: testCase.time
            )
          }
        )
      }
    )
  }
}
