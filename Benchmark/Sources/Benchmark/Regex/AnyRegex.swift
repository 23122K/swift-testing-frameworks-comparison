import Foundation

public struct AnyRegex: RegexComponent {
  public let regex: Regex<AnyRegexOutput>
  
  public init<RegexOutput>(_ regex: Regex<RegexOutput>) {
    self.regex = Regex(regex)
  }
}

public struct RegexError: Error {
  public let value: String
  public let pattern: String
  
  public init(
    value: String,
    using pattern: String
  ) {
    self.value = value
    self.pattern = pattern
  }
}
