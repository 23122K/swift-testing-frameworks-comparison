import Foundation
import Models

extension Xcresult {
//  var summary: TestsSummary {
//    TestsSummary(
//      testPlan: self.testNodes.first(
//        where: { node in node.name == "Test Plan" }
//      )?.name ?? "Test plan name missing",
//      tests: Self._extract(self.testNodes)
//    )
//  }
//  
//  private static func _extract(_ nodes: [TestNode]) -> [TestsSummary.Test] {
//    if nodes.isEmpty { return [] }
//    var tests: [TestsSummary.Test] = []
//    
//    for node in nodes {
//      if node.nodeType == "Test Case" {
//        tests.append(
//          TestsSummary.Test(name: node.name, duration: node.durationInSeconds ?? 0.0)
//        )
//      } else {
//        tests.append(contentsOf: _extract(node.children))
//      }
//    }
//    return tests
//  }
}
