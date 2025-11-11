import ArgumentParser

extension AsyncParsableCommand {
  static func main(@ResultBuilder<String> _ arguments: () -> [String]?) async {
    await Self.main(arguments())
  }
}
