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
  public struct Device: Sendable, Codable, Hashable {
    /// Device architecture e.g. arm64
    public let architecture: String
    
    public let deviceId: String // "00008103-001961CA029A001E",
    public let deviceName: String //"My Mac",
    public let modelName: String // "MacBook Pro",
    public let osBuildNumber: String // "25A362",
    public let osVersion: String //"26.0.1",
    public let platform: String // "macOS"
    
    public init(
      architecture: String,
      deviceId: String,
      deviceName: String,
      modelName: String,
      osBuildNumber: String,
      osVersion: String,
      platform: String
    ) {
      self.architecture = architecture
      self.deviceId = deviceId
      self.deviceName = deviceName
      self.modelName = modelName
      self.osBuildNumber = osBuildNumber
      self.osVersion = osVersion
      self.platform = platform
    }
  }
  
  public struct TestNode: Sendable, Codable, Hashable {
    public let name: String // "swift-loggable-xctests",
    public let duration: String? // "0,035s",
    public let durationInSeconds: Double? // 0.03503894805908203,
    public let nodeIdentifier: String? // "LogMacroXCTests/test_asy
    public let nodeType: String // "Test Plan",
    public let nodeIdentifierURL: String?
    public let result: String? // "Failed"
    public let children: [TestNode]
    
    public init(
      name: String,
      duration: String?,
      durationInSeconds: Double?,
      nodeIdentifier: String?,
      nodeType: String,
      nodeIdentifierURL: String?,
      result: String?,
      children: [TestNode]
    ) {
      self.name = name
      self.duration = duration
      self.durationInSeconds = durationInSeconds
      self.nodeIdentifier = nodeIdentifier
      self.nodeType = nodeType
      self.nodeIdentifierURL = nodeIdentifierURL
      self.result = result
      self.children = children
    }
  }
  
  public struct TestPlanConfigurations: Sendable, Codable, Hashable {
    public let configurationId: String
    public let configurationName: String
    
    public init(
      configurationId: String,
      configurationName: String
    ) {
      self.configurationId = configurationId
      self.configurationName = configurationName
    }
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
