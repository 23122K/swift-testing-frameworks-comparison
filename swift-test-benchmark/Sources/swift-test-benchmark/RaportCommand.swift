import ArgumentParser
import Subprocess

struct RaportCommand: AsyncParsableCommand {
  static let configuration: CommandConfiguration = CommandConfiguration(
    commandName: "raport"
  )
  
  @Flag(name: [.customShort("s"), .customLong("show")], help: "Shows captured summary raport ")
  var shouldShowSummary: Bool = false
  
  @Option
  var generate: Bool = true
  
  var fileManager: FileManagerClient {
    FileManagerClient.shared
  }
  
  mutating func run() async throws {
    try await self.generate()
    if self.shouldShowSummary {
      try self.summary()
    }
  }
  
  func generate() async throws {
    try await withThrowingTaskGroup(of: Raport.self) { group in
      group.addTask {
        try await Subprocess.run(
          Configuration.swift,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Raport.Swift.init(stdout:))
        .map { Raport.swift($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.xcodebuild,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Raport.XcodeBuild.init(stdout:))
        .map { Raport.xcodebuild($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.battery,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Raport.Battery.init(stdout:))
        .map { Raport.battery($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.system,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Raport.System.init(stdout:))
        .map { Raport.system($0) }!
      }
      
      group.addTask {
        try await Subprocess.run(
          Configuration.hardware,
          output: .string(limit: 128*128)
        )
        .standardOutput
        .map(Raport.Hardware.init(stdout:))
        .map { Raport.hardware($0) }!
      }
      
      for try await raport in group {
        switch raport {
          case let .battery(summary):
            try self.fileManager.write(summary, name: "battery.json")
            
          case let .swift(summary):
            try self.fileManager.write(summary, name: "swift.json")
            
          case let .hardware(summary):
            try self.fileManager.write(summary, name: "hardware.json")
            
          case let .system(summary):
            try self.fileManager.write(summary, name: "system.json")
            
          case let .xcodebuild(summary):
            try self.fileManager.write(summary, name: "xcodebuild.json")
        }
      }
    }
  }
  
  func summary() throws {
    let summary = try String(
      describing: Raport.Summary(
        system: self.fileManager.decode(name: "system.json"),
        swift: self.fileManager.decode(name: "swift.json"),
        hardware: self.fileManager.decode(name: "hardware.json"),
        battery: self.fileManager.decode(name: "battery.json"),
        xcodebuild: self.fileManager.decode(name: "xcodebuild.json")
      )
    )
    print(summary)
  }
}

let myJsonData = #"""
{
  "_type": {
    "_name": "ActionsInvocationRecord"
  },
  "actions": {
    "_type": {
      "_name": "Array"
    },
    "_values": [
      {
        "_type": {
          "_name": "ActionRecord"
        },
        "actionResult": {
          "_type": {
            "_name": "ActionResult"
          },
          "coverage": {
            "_type": {
              "_name": "CodeCoverageInfo"
            }
          },
          "issues": {
            "_type": {
              "_name": "ResultIssueSummaries"
            }
          },
          "metrics": {
            "_type": {
              "_name": "ResultMetrics"
            }
          },
          "resultName": {
            "_type": {
              "_name": "String"
            },
            "_value": "action"
          },
          "status": {
            "_type": {
              "_name": "String"
            },
            "_value": "notRequested"
          }
        },
        "buildResult": {
          "_type": {
            "_name": "ActionResult"
          },
          "coverage": {
            "_type": {
              "_name": "CodeCoverageInfo"
            }
          },
          "issues": {
            "_type": {
              "_name": "ResultIssueSummaries"
            }
          },
          "logRef": {
            "_type": {
              "_name": "Reference"
            },
            "id": {
              "_type": {
                "_name": "String"
              },
              "_value": "0~9TOEevIfET0jGhG_4H3mddMxVf6jpkxAqk9e480NCAlTGqFPd4k_T7aeP0RnMxP4qGXedGZUu2NkGZgb_Bencg=="
            },
            "targetType": {
              "_type": {
                "_name": "TypeDefinition"
              },
              "name": {
                "_type": {
                  "_name": "String"
                },
                "_value": "ActivityLogSection"
              }
            }
          },
          "metrics": {
            "_type": {
              "_name": "ResultMetrics"
            }
          },
          "resultName": {
            "_type": {
              "_name": "String"
            },
            "_value": "build"
          },
          "status": {
            "_type": {
              "_name": "String"
            },
            "_value": "succeeded"
          }
        },
        "endedTime": {
          "_type": {
            "_name": "Date"
          },
          "_value": "2025-10-20T23:44:19.277+0200"
        },
        "runDestination": {
          "_type": {
            "_name": "ActionRunDestinationRecord"
          },
          "displayName": {
            "_type": {
              "_name": "String"
            },
            "_value": "Benchmark"
          },
          "localComputerRecord": {
            "_type": {
              "_name": "ActionDeviceRecord"
            },
            "busSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "cpuCount": {
              "_type": {
                "_name": "Int"
              },
              "_value": "1"
            },
            "cpuKind": {
              "_type": {
                "_name": "String"
              },
              "_value": "Apple M1"
            },
            "cpuSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "identifier": {
              "_type": {
                "_name": "String"
              },
              "_value": "00008103-001961CA029A001E"
            },
            "isConcreteDevice": {
              "_type": {
                "_name": "Bool"
              },
              "_value": "true"
            },
            "logicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "8"
            },
            "modelCode": {
              "_type": {
                "_name": "String"
              },
              "_value": "MacBookPro17,1"
            },
            "modelName": {
              "_type": {
                "_name": "String"
              },
              "_value": "MacBook Pro"
            },
            "modelUTI": {
              "_type": {
                "_name": "String"
              },
              "_value": "com.apple.macbookpro-13-retina-touchid-late-2020"
            },
            "name": {
              "_type": {
                "_name": "String"
              },
              "_value": "My Mac"
            },
            "nativeArchitecture": {
              "_type": {
                "_name": "String"
              },
              "_value": "arm64e"
            },
            "operatingSystemVersion": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0.1"
            },
            "operatingSystemVersionWithBuildNumber": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0.1 (25A362)"
            },
            "physicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "8"
            },
            "platformRecord": {
              "_type": {
                "_name": "ActionPlatformRecord"
              },
              "identifier": {
                "_type": {
                  "_name": "String"
                },
                "_value": "com.apple.platform.macosx"
              },
              "userDescription": {
                "_type": {
                  "_name": "String"
                },
                "_value": "macOS"
              }
            },
            "ramSizeInMegabytes": {
              "_type": {
                "_name": "Int"
              },
              "_value": "16384"
            }
          },
          "targetArchitecture": {
            "_type": {
              "_name": "String"
            },
            "_value": "arm64"
          },
          "targetDeviceRecord": {
            "_type": {
              "_name": "ActionDeviceRecord"
            },
            "busSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "cpuCount": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "cpuSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "identifier": {
              "_type": {
                "_name": "String"
              },
              "_value": "48046075-66A5-4592-A345-E076BE91D782"
            },
            "isConcreteDevice": {
              "_type": {
                "_name": "Bool"
              },
              "_value": "true"
            },
            "logicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "modelCode": {
              "_type": {
                "_name": "String"
              },
              "_value": "iPhone18,1"
            },
            "modelName": {
              "_type": {
                "_name": "String"
              },
              "_value": "iPhone 17 Pro"
            },
            "modelUTI": {
              "_type": {
                "_name": "String"
              },
              "_value": "com.apple.com.apple.iphone-17-pro-2"
            },
            "name": {
              "_type": {
                "_name": "String"
              },
              "_value": "Benchmark"
            },
            "nativeArchitecture": {
              "_type": {
                "_name": "String"
              },
              "_value": "arm64"
            },
            "operatingSystemVersion": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0"
            },
            "operatingSystemVersionWithBuildNumber": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0 (23A343)"
            },
            "physicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "platformRecord": {
              "_type": {
                "_name": "ActionPlatformRecord"
              },
              "identifier": {
                "_type": {
                  "_name": "String"
                },
                "_value": "com.apple.platform.iphonesimulator"
              },
              "userDescription": {
                "_type": {
                  "_name": "String"
                },
                "_value": "iOS Simulator"
              }
            },
            "ramSizeInMegabytes": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            }
          },
          "targetSDKRecord": {
            "_type": {
              "_name": "ActionSDKRecord"
            },
            "identifier": {
              "_type": {
                "_name": "String"
              },
              "_value": "iphonesimulator26.0"
            },
            "name": {
              "_type": {
                "_name": "String"
              },
              "_value": "Simulator - iOS 26.0"
            },
            "operatingSystemVersion": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0"
            }
          }
        },
        "schemeCommandName": {
          "_type": {
            "_name": "String"
          },
          "_value": "Run"
        },
        "schemeTaskName": {
          "_type": {
            "_name": "String"
          },
          "_value": "Build"
        },
        "startedTime": {
          "_type": {
            "_name": "Date"
          },
          "_value": "2025-10-20T23:44:18.734+0200"
        },
        "title": {
          "_type": {
            "_name": "String"
          },
          "_value": "Clean \"bitchat (iOS)\""
        }
      },
      {
        "_type": {
          "_name": "ActionRecord"
        },
        "actionResult": {
          "_type": {
            "_name": "ActionResult"
          },
          "coverage": {
            "_type": {
              "_name": "CodeCoverageInfo"
            },
            "archiveRef": {
              "_type": {
                "_name": "Reference"
              },
              "id": {
                "_type": {
                  "_name": "String"
                },
                "_value": "0~nxZqEkVehNs9xe8nCLu60aVmoMivDQQiqJe1UpK3brVJBBB2G4lJjINU6deSfcu4XSnz6F99ziDbRdIP6gc4GQ=="
              }
            },
            "hasCoverageData": {
              "_type": {
                "_name": "Bool"
              },
              "_value": "true"
            },
            "reportRef": {
              "_type": {
                "_name": "Reference"
              },
              "id": {
                "_type": {
                  "_name": "String"
                },
                "_value": "0~JeS5yc0s5krpU6yCo5ZnY3zc3ssNbWwr0t7Px9tjefrXF5JeAwdnTrEScgj3lco-eJBbiiL57sbFRhPrgYFxYA=="
              }
            }
          },
          "diagnosticsRef": {
            "_type": {
              "_name": "Reference"
            },
            "id": {
              "_type": {
                "_name": "String"
              },
              "_value": "0~RWO5T98LyVI36gHrxXacVRcArwhGhJjcFOo3qGaHb8Xi9rhKTXXkBUwWsiWQ5Dmqkm3foXL4hwY0DPtKQRZwsg=="
            }
          },
          "issues": {
            "_type": {
              "_name": "ResultIssueSummaries"
            },
            "testFailureSummaries": {
              "_type": {
                "_name": "Array"
              },
              "_values": [
                {
                  "_type": {
                    "_name": "TestFailureIssueSummary",
                    "_supertype": {
                      "_name": "IssueSummary"
                    }
                  },
                  "documentLocationInCreatingWorkspace": {
                    "_type": {
                      "_name": "DocumentLocation"
                    },
                    "concreteTypeName": {
                      "_type": {
                        "_name": "String"
                      },
                      "_value": "DVTTextDocumentLocation"
                    },
                    "url": {
                      "_type": {
                        "_name": "String"
                      },
                      "_value": "file:///Users/maciag/Developer/bitchat/bitchatTests/GossipSyncManagerTests.swift#EndingLineNumber=13&StartingLineNumber=13"
                    }
                  },
                  "issueType": {
                    "_type": {
                      "_name": "String"
                    },
                    "_value": "Uncategorized"
                  },
                  "message": {
                    "_type": {
                      "_name": "String"
                    },
                    "_value": "Issue recorded: Confirmation was confirmed 0 times, but expected to be confirmed 1 time\nsync request sent"
                  },
                  "testCaseName": {
                    "_type": {
                      "_name": "String"
                    },
                    "_value": "GossipSyncManagerTests.concurrentPacketIntakeAndSyncRequest()"
                  }
                }
              ]
            }
          },
          "logRef": {
            "_type": {
              "_name": "Reference"
            },
            "id": {
              "_type": {
                "_name": "String"
              },
              "_value": "0~ucoYypTYw6i3Tfhj8mFihG04pQ_5ybLO6oSAADV8K8dzS8KnoL3eYx9RfAUiFCrPOkRWdpHtnYeNvs769Oy9Ww=="
            },
            "targetType": {
              "_type": {
                "_name": "TypeDefinition"
              },
              "name": {
                "_type": {
                  "_name": "String"
                },
                "_value": "ActivityLogSection"
              }
            }
          },
          "metrics": {
            "_type": {
              "_name": "ResultMetrics"
            },
            "testsCount": {
              "_type": {
                "_name": "Int"
              },
              "_value": "181"
            },
            "testsFailedCount": {
              "_type": {
                "_name": "Int"
              },
              "_value": "1"
            }
          },
          "resultName": {
            "_type": {
              "_name": "String"
            },
            "_value": "action"
          },
          "status": {
            "_type": {
              "_name": "String"
            },
            "_value": "failed"
          },
          "testsRef": {
            "_type": {
              "_name": "Reference"
            },
            "id": {
              "_type": {
                "_name": "String"
              },
              "_value": "0~JX3k9hOyInzPo9B1TyPzdQEtRHoaUH0oH064KhYXnj_gtMpQ2TVLtA4Y470SLvhXUP-McDEv8PZjku8JeB96oQ=="
            },
            "targetType": {
              "_type": {
                "_name": "TypeDefinition"
              },
              "name": {
                "_type": {
                  "_name": "String"
                },
                "_value": "ActionTestPlanRunSummaries"
              }
            }
          }
        },
        "buildResult": {
          "_type": {
            "_name": "ActionResult"
          },
          "coverage": {
            "_type": {
              "_name": "CodeCoverageInfo"
            }
          },
          "issues": {
            "_type": {
              "_name": "ResultIssueSummaries"
            }
          },
          "logRef": {
            "_type": {
              "_name": "Reference"
            },
            "id": {
              "_type": {
                "_name": "String"
              },
              "_value": "0~V6V47kObmNRpULIjkUYSeZtEHgYWJadoIWeihGBfBPIfDH9MTciqXDycWVUi-857JHv2OZ-31rHfstMRGHFXxw=="
            },
            "targetType": {
              "_type": {
                "_name": "TypeDefinition"
              },
              "name": {
                "_type": {
                  "_name": "String"
                },
                "_value": "ActivityLogSection"
              }
            }
          },
          "metrics": {
            "_type": {
              "_name": "ResultMetrics"
            }
          },
          "resultName": {
            "_type": {
              "_name": "String"
            },
            "_value": "build"
          },
          "status": {
            "_type": {
              "_name": "String"
            },
            "_value": "succeeded"
          }
        },
        "endedTime": {
          "_type": {
            "_name": "Date"
          },
          "_value": "2025-10-20T23:45:57.359+0200"
        },
        "runDestination": {
          "_type": {
            "_name": "ActionRunDestinationRecord"
          },
          "displayName": {
            "_type": {
              "_name": "String"
            },
            "_value": "Benchmark"
          },
          "localComputerRecord": {
            "_type": {
              "_name": "ActionDeviceRecord"
            },
            "busSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "cpuCount": {
              "_type": {
                "_name": "Int"
              },
              "_value": "1"
            },
            "cpuKind": {
              "_type": {
                "_name": "String"
              },
              "_value": "Apple M1"
            },
            "cpuSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "identifier": {
              "_type": {
                "_name": "String"
              },
              "_value": "00008103-001961CA029A001E"
            },
            "isConcreteDevice": {
              "_type": {
                "_name": "Bool"
              },
              "_value": "true"
            },
            "logicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "8"
            },
            "modelCode": {
              "_type": {
                "_name": "String"
              },
              "_value": "MacBookPro17,1"
            },
            "modelName": {
              "_type": {
                "_name": "String"
              },
              "_value": "MacBook Pro"
            },
            "modelUTI": {
              "_type": {
                "_name": "String"
              },
              "_value": "com.apple.macbookpro-13-retina-touchid-late-2020"
            },
            "name": {
              "_type": {
                "_name": "String"
              },
              "_value": "My Mac"
            },
            "nativeArchitecture": {
              "_type": {
                "_name": "String"
              },
              "_value": "arm64e"
            },
            "operatingSystemVersion": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0.1"
            },
            "operatingSystemVersionWithBuildNumber": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0.1 (25A362)"
            },
            "physicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "8"
            },
            "platformRecord": {
              "_type": {
                "_name": "ActionPlatformRecord"
              },
              "identifier": {
                "_type": {
                  "_name": "String"
                },
                "_value": "com.apple.platform.macosx"
              },
              "userDescription": {
                "_type": {
                  "_name": "String"
                },
                "_value": "macOS"
              }
            },
            "ramSizeInMegabytes": {
              "_type": {
                "_name": "Int"
              },
              "_value": "16384"
            }
          },
          "targetArchitecture": {
            "_type": {
              "_name": "String"
            },
            "_value": "arm64"
          },
          "targetDeviceRecord": {
            "_type": {
              "_name": "ActionDeviceRecord"
            },
            "busSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "cpuCount": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "cpuSpeedInMHz": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "identifier": {
              "_type": {
                "_name": "String"
              },
              "_value": "48046075-66A5-4592-A345-E076BE91D782"
            },
            "isConcreteDevice": {
              "_type": {
                "_name": "Bool"
              },
              "_value": "true"
            },
            "logicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "modelCode": {
              "_type": {
                "_name": "String"
              },
              "_value": "iPhone18,1"
            },
            "modelName": {
              "_type": {
                "_name": "String"
              },
              "_value": "iPhone 17 Pro"
            },
            "modelUTI": {
              "_type": {
                "_name": "String"
              },
              "_value": "com.apple.com.apple.iphone-17-pro-2"
            },
            "name": {
              "_type": {
                "_name": "String"
              },
              "_value": "Benchmark"
            },
            "nativeArchitecture": {
              "_type": {
                "_name": "String"
              },
              "_value": "arm64"
            },
            "operatingSystemVersion": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0"
            },
            "operatingSystemVersionWithBuildNumber": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0 (23A343)"
            },
            "physicalCPUCoresPerPackage": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            },
            "platformRecord": {
              "_type": {
                "_name": "ActionPlatformRecord"
              },
              "identifier": {
                "_type": {
                  "_name": "String"
                },
                "_value": "com.apple.platform.iphonesimulator"
              },
              "userDescription": {
                "_type": {
                  "_name": "String"
                },
                "_value": "iOS Simulator"
              }
            },
            "ramSizeInMegabytes": {
              "_type": {
                "_name": "Int"
              },
              "_value": "0"
            }
          },
          "targetSDKRecord": {
            "_type": {
              "_name": "ActionSDKRecord"
            },
            "identifier": {
              "_type": {
                "_name": "String"
              },
              "_value": "iphonesimulator26.0"
            },
            "name": {
              "_type": {
                "_name": "String"
              },
              "_value": "Simulator - iOS 26.0"
            },
            "operatingSystemVersion": {
              "_type": {
                "_name": "String"
              },
              "_value": "26.0"
            }
          }
        },
        "schemeCommandName": {
          "_type": {
            "_name": "String"
          },
          "_value": "Test"
        },
        "schemeTaskName": {
          "_type": {
            "_name": "String"
          },
          "_value": "BuildAndAction"
        },
        "startedTime": {
          "_type": {
            "_name": "Date"
          },
          "_value": "2025-10-20T23:44:19.279+0200"
        },
        "testPlanName": {
          "_type": {
            "_name": "String"
          },
          "_value": "bitchat (iOS)"
        },
        "title": {
          "_type": {
            "_name": "String"
          },
          "_value": "Testing project bitchat with scheme bitchat (iOS)"
        }
      }
    ]
  },
  "issues": {
    "_type": {
      "_name": "ResultIssueSummaries"
    }
  },
  "metadataRef": {
    "_type": {
      "_name": "Reference"
    },
    "id": {
      "_type": {
        "_name": "String"
      },
      "_value": "0~hEPytyxefZHz0c3w879FevTP3JbUGm4iqWgOw1HQce-fCqWHIvaI-1hHX0GdaFprsMl-47LbBfHHzA115NPzRg=="
    },
    "targetType": {
      "_type": {
        "_name": "TypeDefinition"
      },
      "name": {
        "_type": {
          "_name": "String"
        },
        "_value": "ActionsInvocationMetadata"
      }
    }
  },
  "metrics": {
    "_type": {
      "_name": "ResultMetrics"
    },
    "testsCount": {
      "_type": {
        "_name": "Int"
      },
      "_value": "181"
    },
    "testsFailedCount": {
      "_type": {
        "_name": "Int"
      },
      "_value": "1"
    }
  }
}
"""#.data(using: .utf8)
