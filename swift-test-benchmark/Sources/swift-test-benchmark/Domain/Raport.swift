public enum Raport: Sendable, Codable {
  case system(System)
  case swift(Swift)
  case hardware(Hardware)
  case battery(Battery)
  case xcodebuild(XcodeBuild)
}

extension Raport {
  public struct Summary: Sendable {
    public let system: System?
    public let swift: Swift?
    public let hardware: Hardware?
    public let battery: Battery?
    public let xcodebuild: XcodeBuild?
    
    public init(
      system: System?,
      swift: Swift?,
      hardware: Hardware?,
      battery: Battery?,
      xcodebuild: XcodeBuild?
    ) {
      self.system = system
      self.swift = swift
      self.hardware = hardware
      self.battery = battery
      self.xcodebuild = xcodebuild
    }
  }
}

extension Raport.Summary: CustomStringConvertible {
  public var description: String {
    """
    Raport summary
    
    system: \(String(describing: self.system))
    swift: \(String(describing: self.swift))
    hardware: \(String(describing: self.hardware))
    battery: \(String(describing: self.battery))
    xcodebuild: \(String(describing: self.xcodebuild))
    """
  }
}

extension Raport {
  public enum Failure: Error {
    case stdout(String?)
  }
}
