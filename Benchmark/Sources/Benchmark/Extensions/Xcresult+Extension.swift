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
  var summary: TestsSummary {
    TestsSummary(
      testPlan: self.testNodes.first(
        where: { node in node.name == "Test Plan" }
      )?.name ?? "Test plan name missing",
      tests: Self._extract(self.testNodes)
    )
  }
  
  private static func _extract(_ nodes: [TestNode]) -> [TestsSummary.Test] {
    if nodes.isEmpty { return [] }
    var tests: [TestsSummary.Test] = []
    
    for node in nodes {
      if node.nodeType == "Test Case" {
        tests.append(
          TestsSummary.Test(name: node.name, duration: node.durationInSeconds ?? 0.0)
        )
      } else {
        tests.append(contentsOf: _extract(node.children))
      }
    }
    return tests
  }
}
