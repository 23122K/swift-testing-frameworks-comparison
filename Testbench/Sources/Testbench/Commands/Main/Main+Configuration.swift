import ArgumentParser

extension MainCommand {
  public static let configuration = CommandConfiguration(
    commandName: "testbench",
    subcommands: [
      ReportCommand.self,
      XcodebuildCommand.self,
      ResultsCommand.self,
    ]
  )
}
