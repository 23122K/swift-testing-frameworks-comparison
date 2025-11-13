import Foundation
import Models

extension Xcresult {
  public struct Summary {
    public let totalTests: Int
    public let totalDuration: Double
  }
  
  public static func _extract(_ nodes: [TestNode]) -> [(String, Double)] {
    if nodes.isEmpty { return [] }
    var tests: [(String, Double)] = []
    
    for node in nodes {
      if node.nodeType == "Test Case" {
        tests.append(
          (node.name, node.durationInSeconds ?? 0.0)
        )
      } else {
        tests.append(contentsOf: _extract(node.children))
      }
    }
    return tests
  }
}
