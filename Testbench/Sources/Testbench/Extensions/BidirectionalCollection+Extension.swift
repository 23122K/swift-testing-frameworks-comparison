extension BidirectionalCollection where Self.SubSequence == Substring {
  func match(
    using regex: AnyRegex,
    ignore regexes: [AnyRegex] = []
  ) -> Regex<AnyRegex.RegexOutput>.Match? {
    for regex in regexes.compactMap(\.self) {
      guard self.firstMatch(of: regex) == nil
      else { return nil }
      continue
    }
    
    return self.firstMatch(of: regex)
  }
}
