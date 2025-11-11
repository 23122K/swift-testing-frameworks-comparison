public enum Report: Sendable, Codable {
  case system(System)
  case swift(Swift)
  case hardware(Hardware)
  case battery(Battery)
  case xcodebuild(Xcodebuild)
}

extension Report {
  public struct Summary: Sendable {
    public let system: System
    public let swift: Swift
    public let hardware: Hardware
    public let battery: Battery
    public let xcodebuild: Xcodebuild
    
    public init(
      system: System,
      swift: Swift,
      hardware: Hardware,
      battery: Battery,
      xcodebuild: Xcodebuild
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
    System report summary:\n\(indent(describing: self.system))\n
    Swift report summary:\n\(indent(describing: self.swift))\n
    Hardware report summary:\n\(indent(describing: self.hardware))\n
    Battery report summary:\n\(indent(describing: self.battery))\n
    Xcodebuild report summary:\n\(indent(describing: self.xcodebuild))\n 
    """
  }
  
  private func indent(describing value: CustomStringConvertible) -> String {
    value
      .description
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map { "\t\($0)" }
      .joined(separator: "\n")
  }
}

extension Report {
  public enum Failure: Error {
    case stdout(String?)
  }
}
