import Foundation

public enum TestFramework<
  XctestOptions: Sendable,
  TestingOptions: Sendable
>: Sendable {
  case xctest(XctestOptions)
  case swiftTesting(TestingOptions)
}

extension TestFramework: CustomStringConvertible {
  public var description: String {
    switch self {
      case .xctest:
        return "XCTest"
        
      case .swiftTesting:
        return "Swift Testing"
    }
  }
}

extension TestFramework: CustomDebugStringConvertible {
  public var debugDescription: String {
    """
    \(String(describing: self))
    \(_debugOptionsDescription)
    """
  }
  
  private var _debugOptionsDescription: String {
    switch self {
    case let .xctest(options):
      String(reflecting: options)
        
    case let .swiftTesting(options):
      String(reflecting: options)
    }
  }
}

extension TestFramework: Equatable where XctestOptions: Equatable, TestingOptions: Equatable {}
extension TestFramework: Hashable where XctestOptions: Hashable, TestingOptions: Hashable {}
