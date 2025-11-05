import Foundation

/// A type representing root structure of tests.
public struct Xcresult: Sendable, Codable, Hashable {
  public let devices: [Device]
  public let testNodes: [TestNode]
  public let testPlanConfigurations: [TestPlanConfigurations]
  
  public init(
    devices: [Device],
    testNodes: [TestNode],
    testPlanConfigurations: [TestPlanConfigurations]
  ) {
    self.devices = devices
    self.testNodes = testNodes
    self.testPlanConfigurations = testPlanConfigurations
  }
}

extension Xcresult {
  static func testsDurationInSeconds(_ nodes: [TestNode]) -> [String: Double] {
    if nodes.isEmpty { return [:] }
    var result: [String: Double] = [:]
    for node in nodes {
      if let durationInSeconds = node.durationInSeconds {
        result[node.name] = durationInSeconds
      } else {
        result.merge(
          Self.testsDurationInSeconds(node.children),
          uniquingKeysWith: { $1 }
        )
      }
    }
    return result
  }
}

extension Xcresult {
  public struct Device: Sendable, Codable, Hashable {
    let architecture: String // "arm64",
    let deviceId: String // "00008103-001961CA029A001E",
    let deviceName: String //"My Mac",
    let modelName: String // "MacBook Pro",
    let osBuildNumber: String // "25A362",
    let osVersion: String //"26.0.1",
    let platform: String // "macOS"
  }
  
  public struct TestNode: Sendable, Codable, Hashable {
    let name: String // "swift-loggable-xctests",
    let duration: String? // "0,035s",
    let durationInSeconds: Double? // 0.03503894805908203,
    let nodeIdentifier: String? // "LogMacroXCTests/test_asy
    let nodeType: String // "Test Plan",
    let nodeIdentifierURL: String?
    let result: String? // "Failed"
    let children: [TestNode]
    
    var totalDurationInSeconds: Double {
      if let durationInSeconds {
        return durationInSeconds
      } else {
        return self.children.reduce(into: 0.0) { result, test in
          result += test.totalDurationInSeconds
        }
      }
    }
  }
  
  public struct TestPlanConfigurations: Sendable, Codable, Hashable {
    let configurationId: String
    let configurationName: String
  }
}

extension Xcresult {
  public init(
    url: URL,
    decoder: JSONDecoder = JSONDecoder()
  ) throws {
    guard let data = FileManager.default.contents(atPath: url.path())
    else { throw NSError(domain: "BenchmarkDomain", code: 4) }
    let _self = try decoder.decode(Self.self, from: data)
    
    self.devices = _self.devices
    self.testNodes = _self.testNodes
    self.testPlanConfigurations = _self.testPlanConfigurations
  }
}

extension Xcresult.TestNode {
  public init(from decoder: any Decoder) throws {
    let container: KeyedDecodingContainer<Xcresult.TestNode.CodingKeys> = try decoder.container(
      keyedBy: Xcresult.TestNode.CodingKeys.self
    )
    
    self.name = try container.decode(
      String.self,
      forKey: Xcresult.TestNode.CodingKeys.name
    )
    
    self.duration = try container.decodeIfPresent(
      String.self,
      forKey: Xcresult.TestNode.CodingKeys.duration
    )
    
    self.durationInSeconds = try container.decodeIfPresent(
      Double.self,
      forKey: Xcresult.TestNode.CodingKeys.durationInSeconds
    )
    
    self.nodeIdentifier = try container.decodeIfPresent(
      String.self,
      forKey: Xcresult.TestNode.CodingKeys.nodeIdentifier
    )
    
    self.nodeType = try container.decode(
      String.self,
      forKey: Xcresult.TestNode.CodingKeys.nodeType
    )
    
    self.nodeIdentifierURL = try container.decodeIfPresent(
      String.self,
      forKey: Xcresult.TestNode.CodingKeys.nodeIdentifierURL
    )
    
    self.result = try container.decodeIfPresent(
      String.self,
      forKey: Xcresult.TestNode.CodingKeys.result
    )
    
    self.children = try container.decodeIfPresent(
      [Xcresult.TestNode].self,
      forKey: Xcresult.TestNode.CodingKeys.children
    ) ?? []
  }
}
