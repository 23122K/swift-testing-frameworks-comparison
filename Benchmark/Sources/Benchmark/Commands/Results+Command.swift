import ArgumentParser
import Factory
import Storage
import Defaults

public struct ResultsCommand: AsyncParsableCommand {
  @Flag(
    name: [
      .customShort("v"),
      .customLong("verbose")
    ]
  )
  var isVerbose: Bool = false
  
  @Flag(
    name: .customLong("delete")
  )
  var shouldDeleteCapturedContent: Bool = false
  
  var strage: Storage {
    @Injected(\.storage) var storage
    return storage
  }
  
  var defaults: Defaults {
    @Injected(\.defaults) var defaults
    return defaults
  }
  
  public func run() async throws {
    if self.shouldDeleteCapturedContent {
      try await self.deleteAllCapturedContent()
      print("All content removed succesfully")
    }
  }
  
  public func deleteAllCapturedContent() async throws {
    let path = self.strage.directory()
    if self.isVerbose {
      print("Deleting files at \(path)")
    }
    try self.strage.delete(path)
    
    if self.isVerbose {
      print("Deleteing UserDefaults")
    }
    for key in Defaults.Key.allCases {
      self.defaults.delete(forKey: key)
    }
  }
  
  public init() {}
}

extension ResultsCommand {
  public static let configuration = CommandConfiguration(
    commandName: "results"
  )
}
