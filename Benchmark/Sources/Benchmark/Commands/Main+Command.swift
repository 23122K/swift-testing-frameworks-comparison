import ArgumentParser
import Subprocess
import Storage
import Models

@main
struct MainCommand: AsyncParsableCommand {
  @Flag(
    name: [
      .customShort("v"),
      .customLong("verbose")
    ]
  )
  var isVerbose: Bool = false
  
  mutating func run() async throws {
    // Do the stuff
  }
}

// MARK: - Command Configuration
extension MainCommand {
  static let storage = Storage.live
  static let configuration = CommandConfiguration(
    commandName: "benchmark",
    subcommands: [
      ReportCommand.self,
      TestCommand.self
    ],
    defaultSubcommand: ReportCommand.self
  )
}
