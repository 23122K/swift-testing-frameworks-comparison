import Dependencies

extension DependencyValues {
  public var storage: Storage {
    get { self[Storage.self] }
    set { self[Storage.self] = newValue }
  }
}
