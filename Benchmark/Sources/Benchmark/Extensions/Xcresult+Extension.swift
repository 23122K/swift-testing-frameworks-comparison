import Foundation
import Storage
import Models

extension Xcresult {
  public init(
    at url: URL,
    decoder: JSONDecoder = JSONDecoder(),
    data: (URL) throws -> Data = { url in try Storage.shared.contents(url) }
  ) throws {
    let data = try data(url)
    let decoded = try decoder.decode(Self.self, from: data)
    
    self.init(
      devices: decoded.devices,
      testNodes: decoded.testNodes,
      testPlanConfigurations: decoded.testPlanConfigurations
    )
  }
}

extension Xcresult {
  var testsCount: Int {
    Self._sumTestCount(self.testNodes)
  }
  
  private static func _sumTestCount(_ nodes: [TestNode]) -> Int {
    if nodes.isEmpty { return 0 }
    var tests = 0
    for node in nodes {
      if node.nodeType == "Test Case" {
        tests += 1
      } else {
        tests += _sumTestCount(node.children)
      }
    }
    return tests
  }
}
