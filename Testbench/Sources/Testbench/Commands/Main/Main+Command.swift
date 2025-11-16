import ArgumentParser
import Factory
import Foundation
import Subprocess
import DefaultsClient
import StorageClient
import Models
import DateClient

@main
struct MainCommand: AsyncParsableCommand {
  @OptionGroup
  var common: CommonOptions
  
  @Flag(
    name: [
      .customShort("p"),
      .customLong("path")
    ],
    help: "Show path to repository"
  )
  var shouldShowPath: Bool = false
  
  @Option(
    name: .customLong("set-path"),
    help: """
    Set a path
    
    A path must be ../swift-testing-frameworks-comparison repository. 
    Set globaly, used to copy and prepate results.
    """
  )
  var path: String? = nil
  
  mutating func run() async throws {
    if self.common.isVerbose, let date: Date = try self.defaults.get(forKey: .lastTestbenchUsage) {
      print("Last usage: \(date.formatted(date: .numeric, time: .standard))")
    }
    
    if
      (self.common.isVerbose || self.shouldShowPath),
      let repositoryPath: String = try self.defaults.get(forKey: .repositoryURL)
    {
      print("Repository path: \(repositoryPath)")
    }
    
    if let path = self.path {
      let url = URL(filePath: path, directoryHint: .isDirectory)
      let contents = try self.storage.contentsOfDirectory(url)
      if contents.contains(
        where: { $0 == ".testbench" }
      ) {
        self.defaults.set(url.path(), forKey: .repositoryURL)
        print("Path set to: \(url.path())")
      } else {
        print("Invalid path: \(url.path())")
        print("Path must point at swift-testing-fameworks-comparison repostory")
      }
    }
  }
}

extension MainCommand {
  fileprivate var storage: StorageClient {
    @Injected(\.storage) var storage
    return storage
  }
  
  fileprivate var defaults: DefaultsClient {
    @Injected(\.defaults) var defaults
    return defaults
  }
  
  fileprivate var now: Date {
    @Injected(\.date) var date
    return date.now()
  }
}
