import Foundation

extension UserDefaults {
  func _value(
    forKey key: Defaults.Key, as type: Any.Type
  ) throws(Defaults.Failure) -> any Sendable {
    switch type {
      case let type where type == Bool.self, let type where type == Bool?.self:
        return self.bool(forKey: key.rawValue)
        
      case let type where type == Date.self, let type where type == Date?.self:
        return self.object(forKey: key.rawValue) as? Date
        
      default:
        throw Defaults.Failure.typeNotSupported(type)
    }
  }
}
