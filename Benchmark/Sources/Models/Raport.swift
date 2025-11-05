public enum Report: Sendable, Codable {
  case system(System)
  case swift(Swift)
  case hardware(Hardware)
  case battery(Battery)
  case xcodebuild(XcodeBuild)
}

extension Report {
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

extension Report.Summary: CustomStringConvertible {
  public var description: String {
    """
    Report summary
    
    system: \(String(describing: self.system))
    swift: \(String(describing: self.swift))
    hardware: \(String(describing: self.hardware))
    battery: \(String(describing: self.battery))
    xcodebuild: \(String(describing: self.xcodebuild))
    """
  }
}

extension Report {
  public enum Failure: Error {
    case stdout(String?)
  }
}
