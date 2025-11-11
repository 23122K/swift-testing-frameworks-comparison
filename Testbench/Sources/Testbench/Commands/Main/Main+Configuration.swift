import ArgumentParser

extension MainCommand {
  public static let configuration = CommandConfiguration(
    commandName: "testbench",
    subcommands: [
      ReportCommand.self,
      TestingCommand.self,
      XCTestCommand.self,
      ResultsCommand.self,
    ]
  )
}
