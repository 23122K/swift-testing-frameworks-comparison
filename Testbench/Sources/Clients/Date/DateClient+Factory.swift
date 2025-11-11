import Factory
import Foundation

public final class DateClient: Sendable {
  public let now: @Sendable () -> Date
  
  public init(now: @Sendable @escaping () -> Date) {
    self.now = now
  }
}

extension DateClient: ManagedContainer {
  public var manager: ContainerManager {
    ContainerManager()
  }
}

extension DateClient: SharedContainer {
  @TaskLocal
  public static var shared = DateClient(
    now: {
      Date.now
    }
  )
}

extension SharedContainer {
  public var date: Factory<DateClient> {
    self { DateClient.shared }
  }
}
