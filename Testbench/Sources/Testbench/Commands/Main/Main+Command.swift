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
    ]
  )
  var isVerbose: Bool = false

  mutating func run() async throws {
    if let date: Date = try self.defaults.get(forKey: .lastTestbenchUsage) {
      let authorName: String? = try self.defaults .get(forKey: .authorName)
      print("Welcome \(authorName ?? ""), last usage: \(date.formatted(date: .numeric, time: .standard))")
    } else {
      print("Welcome!")
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
