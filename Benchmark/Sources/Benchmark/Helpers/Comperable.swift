import Models

struct TestResultsSummary {
  let framework: Framework
  var tests: Test
  
}

extension TestResultsSummary {
  struct Test {
    let name: String
    let duration: Double
  }
  
  enum Framework {
    case xctest
    case testing
  }
}
