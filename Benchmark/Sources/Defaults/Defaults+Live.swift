import Dependencies
import Foundation

extension Defaults: DependencyKey {
  public static let liveValue: Defaults = {
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
