import Factory
import Foundation

extension DefaultsClient: ManagedContainer {
  public var manager: ContainerManager {
    ContainerManager()
  }
}

extension DefaultsClient: SharedContainer {
  @TaskLocal
  public static var shared: DefaultsClient = {
    DefaultsClient(
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
  public var defaults: Factory<DefaultsClient> {
    self { DefaultsClient.shared }
  }
}
