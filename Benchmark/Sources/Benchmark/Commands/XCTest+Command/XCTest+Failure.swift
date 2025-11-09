extension XCTestCommand {
  enum Failure: Error {
    case simulatorNotFound
    case simulatorNotCreated
  }
}
