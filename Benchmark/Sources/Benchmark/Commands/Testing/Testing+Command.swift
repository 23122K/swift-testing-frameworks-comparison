import ArgumentParser
import Subprocess
import Storage
import Factory
import Foundation

public struct TestingCommand: AsyncParsableCommand {
  @Argument
  var packagePath: String
  
  @Argument
  var targets: [String] = []
  
  @Option
  var iterations: Int = 1
  
  public init() {}
  
  public mutating func run() async throws {
    var xunitPaths: [URL] = []
    for iteration in 0 ..< self.iterations {
      let xunitPath = self.xunitPath(iteration: iteration)
      
      try await self.cleanSPM()
      try await self.test(
        path: self.packagePath,
        filter: targets.joined(separator: "|"),
        isParallel: true,
        isXctestSupported: true,
        isSwiftTestingSupported: true,
        xunit: xunitPath.path()
      )
      xunitPaths.append(xunitPath)
    }
  }
  
  private func xunitPath(iteration: Int) -> URL {
    self.storage.directory()
      .appending(path: "testing-iteration-\(iteration)")
      .appendingPathExtension("xml")
  }
}

extension TestingCommand {
  fileprivate var storage: Storage {
    @Injected(\.storage) var storage
    return storage
  }
}
