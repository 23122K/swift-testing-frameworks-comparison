extension Regex<AnyRegexOutput>.Match {
  func `as`<T>(_ type: T.Type) -> T? {
    self.output.extractValues(as: type)
  }
  
  func value() -> String? {
    guard
      let (_, value) = self.output.extractValues(as: (Substring, Substring).self)
    else {
      print("Failed for \(self.output)")
      return nil
    }
    
    return String(value)
  }
}
