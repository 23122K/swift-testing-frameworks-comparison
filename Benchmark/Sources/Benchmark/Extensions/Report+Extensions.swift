import Models

extension Report.Battery {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let batteryPercentage = stdout.firstMatch(of: .batteryStateOfCharge)?.value(),
      let isCharging = stdout.firstMatch(of: .batteryCharging)?.value(),
      let isLowPowerModeOnBatteryEnabled = stdout.firstMatch(of: .batteryBatteryPowerLowPowerMode)?.value(),
      let isLowPowerModeOnAcEnabled = stdout.firstMatch(of: .batteryAcPowerLowPowerMode)?.value()
    else { throw Report.Failure.stdout(stdout) }
    
    self.init(
      batteryPercentage: batteryPercentage,
      isCharging: isCharging,
      isLowPowerModeOnBatteryEnabled: isLowPowerModeOnBatteryEnabled,
      isLowPowerModeOnAcEnabled: isLowPowerModeOnAcEnabled
    )
  }
}

extension Report.Swift {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let version = stdout.firstMatch(of: .swiftVersionPattern)?.value(),
      let target = stdout.firstMatch(of: .swiftTargetPattern)?.value()
    else { throw Report.Failure.stdout(stdout) }
    
    self.init(
      version: version,
      target: target
    )
  }
}

extension Report.Hardware {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let modelName = stdout.firstMatch(of: .hardwareModelName)?.value(),
      let modelIdentifier = stdout.firstMatch(of: .hardwareModelIdentifier)?.value(),
      let modelNumber = stdout.firstMatch(of: .hardwareModelNumber)?.value(),
      let chip = stdout.firstMatch(of: .hardwareChip)?.value(),
      let totalNumberOfCores = stdout.firstMatch(of: .hardwareTotalNumberOfCores)?.value(),
      let memory = stdout.firstMatch(of: .hardwareMemory)?.value(),
      let systemFirmwareVersion = stdout.firstMatch(of: .hardwareSystemFirmwareVersion)?.value()
    else { throw Report.Failure.stdout(stdout) }
    
    self.init(
      modelName: modelName,
      modelIdentifier: modelIdentifier,
      modelNumber: modelNumber,
      chip: chip,
      totalNumberOfCores: totalNumberOfCores,
      memory: memory,
      systemFirmwareVersion: systemFirmwareVersion
    )
  }
}

extension Report.System {
  public init(stdout: String?) throws {
    guard
      let stdout,
      let productName = stdout.firstMatch(of: .systemProductName)?.value(),
      let productVersion = stdout.firstMatch(of: .systemProductVersion)?.value(),
      let buildVersion = stdout.firstMatch(of: .systemBuildVersion)?.value()
    else { throw Report.Failure.stdout(stdout) }
    
    self.init(
      productName: productName,
      productVersion: productVersion,
      buildVersion: buildVersion
    )
  }
}

extension Report.XcodeBuild {
  public init(stdout: String?) throws {
     guard
      let stdout,
      let version = stdout.firstMatch(of: .xcodeVersion)?.value(),
      let buildVersion = stdout.firstMatch(of: .xcodeBuildVersion)?.value()
    else { throw Report.Failure.stdout(stdout) }
    
    self.init(
      version: version,
      buildVersion: buildVersion
    )
  }
}
