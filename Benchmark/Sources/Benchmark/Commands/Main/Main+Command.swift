import ArgumentParser
import Factory
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
  
  var storage: Storage {
    @Injected(\.storage) var storage
    return storage
  }
  
  mutating func run() async throws {
//    if self.isVerbose {
//      print(isVerbose)
//    }
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
  // MARK: - Failure
  enum Failure: Error {
    case batteryLevelToLow
    case lowBatteryModeEnabled
  }
}
