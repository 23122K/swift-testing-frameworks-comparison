extension Defaults {
  public enum Failure: Error {
    case typeNotSupported(Any.Type)
  }
}
