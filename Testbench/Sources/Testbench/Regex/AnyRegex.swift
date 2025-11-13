import Foundation

public struct AnyRegex: RegexComponent {
  public let regex: Regex<AnyRegexOutput>
  
  public init<RegexOutput: Sendable>(_ regex: Regex<RegexOutput>) {
    self.regex = Regex(regex)
  }
}

extension Regex.Match: @unchecked @retroactive Sendable where Regex.RegexOutput == Sendable {}
extension AnyRegex {
  public struct Failure: Error {
    public let match: Regex<RegexOutput>.Match
    public let pattern: String
    
    public init(
      match: Regex<RegexOutput>.Match,
      using pattern: String
    ) {
      self.match = match
      self.pattern = pattern
    }
  }
}
