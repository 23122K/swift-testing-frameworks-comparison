import ArgumentParser
import Factory
import Foundation
import Subprocess
import Defaults
import Storage
import Models
import Date

@main
struct MainCommand: AsyncParsableCommand {
  @Flag(
    name: [
      .customShort("v"),
      .customLong("verbose")
    ],
    help: "Show verbose logging output"
  )
  var isVerbose: Bool = false
  
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
    if self.isVerbose, let date: Date = try self.defaults.get(forKey: .lastTestbenchUsage) {
      print("Last usage: \(date.formatted(date: .numeric, time: .standard))")
    }
    
    if
      (self.isVerbose || self.shouldShowPath),
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

//    await ReportCommand.main {
////      if self.isVerbose {
////        "--print"
////      }
////     
////      "--generate"
////    }
//      
//      if self.isVerbose {
//        print("XD")
//      }
//      return nil
//    
//    let report: Report.Battery = try self.storage.decode(name: "battery.json")
//    if self.isVerbose {
//      print(report)
//    }
//    
////    await XCTestCommand.main()
//
//    // TODO: Check battery percentage and low battery mode before continuing
//    
////    await XCTestCommand.main()
//    // TODO: Get paths to testing targets
//    // TODO: Check if each target contains xctest-benchmark and testing-benchmark
//    
//    // TODO: Check if device is created for tests
//    // TODO: Run xctest-benchmark 10 times
//    // TODO: After tests are completed, convert results into json
//    
//    // TODO: Run testing-benchmark 10 times
//    // TODO: After tests are completed, convert results into json
//    
//    // TODO: Create pull request to a repository containing results
//    // TODO: Remove results
  }
}

extension MainCommand {
  fileprivate var storage: Storage {
    @Injected(\.storage) var storage
    return storage
  }
  
  fileprivate var defaults: Defaults {
    @Injected(\.defaults) var defaults
    return defaults
  }
  
  fileprivate var now: Date {
    @Injected(\.date) var date
    return date.now()
  }
}
