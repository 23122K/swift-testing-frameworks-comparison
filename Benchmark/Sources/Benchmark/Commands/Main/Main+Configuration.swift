import ArgumentParser

extension MainCommand {
  public static let configuration = CommandConfiguration(
    commandName: "benchmark",
    subcommands: [
      ReportCommand.self,
      TestingCommand.self,
      XCTestCommand.self,
      ResultsCommand.self,
    ]
  )
}
