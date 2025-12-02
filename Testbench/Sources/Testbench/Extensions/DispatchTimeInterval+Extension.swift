import Foundation

extension DispatchTimeInterval {
  var seconds: Double {
    switch self {
    case let .seconds(value):
      return Double(value)
      
    case let .milliseconds(value):
      return Double(value) / 1_000
      
    case let .microseconds(value):
      return Double(value) / 1_000_000
      
    case let .nanoseconds(value):
      return Double(value) / 1_000_000_000
    
    default:
      return 0.0
    }
  }
}
