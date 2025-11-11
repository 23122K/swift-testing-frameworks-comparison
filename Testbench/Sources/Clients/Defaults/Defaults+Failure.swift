extension Defaults {
  public enum Failure: Error {
    case typeNotSupported(Any.Type)
    case castingFailed(from: Any.Type, to: Any.Type)
  }
}
