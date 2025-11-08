import Foundation
import Dependencies

public struct Defaults: Sendable {
  var _set: @Sendable (any Sendable, Key) -> Void
  var _get: @Sendable (Key, Any.Type) throws -> any Sendable
  var _delete: @Sendable (Key) -> Void
}

extension Defaults {
  public func set<T: Sendable>(_ value: T, forKey key: Key) {
    self._set(value, key)
  }
  
  public func get<T: Sendable>(forKey key: Key) throws -> T {
    try self._get(key, T.self) as! T
  }
  
  public func delete(forKey key: Key) {
    self._delete(key)
  }
}
