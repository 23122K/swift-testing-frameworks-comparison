import Factory
import Foundation

extension Defaults: ManagedContainer {
  public var manager: ContainerManager {
    ContainerManager()
  }
}

extension Defaults: SharedContainer {
  @TaskLocal
  public static var shared: Defaults = {
    Defaults(
      _set: { value, key in
        UserDefaults.standard.set(value, forKey: key.rawValue)
      },
      _get: { key, type in
        try UserDefaults.standard._value(forKey: key, as: type)
      },
      _delete: { key in
        UserDefaults.standard.removeObject(forKey: key.rawValue)
      }
    )
  }()
}

extension SharedContainer {
  public var defaults: Factory<Defaults> {
    self { Defaults.shared }
  }
}
