import Dependencies

extension DependencyValues {
  public var defaults: Defaults {
    get { self[Defaults.self] }
    set { self[Defaults.self] = newValue }
  }
}
