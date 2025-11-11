import ArgumentParser
import Subprocess
import Storage
import Factory
import Foundation
import Models

public struct TestingCommand: AsyncParsableCommand {
  @Argument
  var packagePath: String = "."
  
  @Argument
  var targets: [String] = ["LoggableMacroXCTests"]
  
  @Option
  var iterations: Int = 2
  
  public init() {}
  
  public mutating func run() async throws {
    var xunitPaths: [URL] = []
    for iteration in 0 ..< self.iterations {
      print("Start of iteration no. \(iteration + 1)")
      let output = self.xunitOutput(iteration: iteration)
      
      print("Cleaning SPM")
      try await self.cleanSPM()
      try await Task.sleep(nanoseconds: 500_000_000)
      
      print("Building package")
      _ = try await Subprocess.run(
        Configuration(
          executable: "swift",
          arguments: {
            "build"
//            "--package-path"; self.packagePath
            "--build-tests"
          }
        ),
        output: .standardOutput,
        error: .string(limit: 128*128)
      )
      
      try await Task.sleep(nanoseconds: 500_000_000)
      print("Testing")
      try await self.test(
        path: self.packagePath,
        filter: targets.joined(separator: "|"),
        isParallel: false,
        isXctestSupported: false,
        isSwiftTestingSupported: true,
        xunit: output.path(),
        shouldSkipBuild: true
      )
      
      print("*")
      // When --xunit-output <Output> flag is passed, two files are created, one specified
      // and second containing postfix swift-testing.
//      try self.storage.delete(output)
      print("*")
      xunitPaths.append(
        self.xunitOutput(
          iteration: iteration,
          hasPostfix: false
        )
      )
      
      print("End of iteration no. \(iteration + 1)")
    }
    
    for xunitPathOutput in xunitPaths {
      print(xunitPathOutput.absoluteString)
      let data = try self.storage.contents(xunitPathOutput)
      let xunit = try XMLDecoder.xunit.decode(Xunit.self, from: data)
    }
  }
  
  private func xunitOutput(
    iteration: Int,
    hasPostfix: Bool = false
  ) -> URL {
    self.storage.directory()
      .appending(
        path: hasPostfix 
          ? "iteration-\(iteration)-swift-testing"
          : "iteration-\(iteration)"
      )
      .appendingPathExtension("xml")
  }
}

extension TestingCommand {
  fileprivate var storage: Storage {
    @Injected(\.storage) var storage
    return storage
  }
}
