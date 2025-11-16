extension XcodebuildCommand {
  enum Failure: Error {
    case simulatorNotFound
    case simulatorNotCreated
  }
}
