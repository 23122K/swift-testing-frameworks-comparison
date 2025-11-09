import Foundation
import Models
import Storage

protocol Comperable {
  func tests() -> [String: Double]
  func count() -> Int
}

extension Xunit {
  public init(
    at url: URL,
    decoder: XMLDecoder = XMLDecoder.xunit,
    data: (URL) throws -> Data = { url in try Storage.shared.contents(url) }
  ) throws {
    let data = try data(url)
    let decoded = try decoder.decode(Self.self, from: data)
    
    self.init(testSuites: decoded.testSuites)
  }
}

extension Xunit: Comperable {
  public func tests() -> [String: Double] {
    self.testSuites
      .flatMap(\.testCases)
      .reduce(into: [String: Double]()) { result, testCase in
        result[testCase.name] = testCase.time
      }
  }
  
  public func count() -> Int {
    self.testSuites
      .reduce(into: 0) { result, testSuite in
        result += testSuite.tests
      }
  }
}


