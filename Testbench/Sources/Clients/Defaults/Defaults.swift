import Factory

public final class Defaults: Sendable {
  let _set: @Sendable (any Sendable, Key) -> Void
  let _get: @Sendable (Key, Any.Type) throws -> any Sendable
  let _delete: @Sendable (Key) -> Void
  
  init(
    _set: @Sendable @escaping (any Sendable, Key) -> Void,
    _get: @Sendable @escaping (Key, Any) throws -> any Sendable,
    _delete: @Sendable @escaping (Key) -> Void
  ) {
    self._set = _set
    self._get = _get
    self._delete = _delete
  }
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
