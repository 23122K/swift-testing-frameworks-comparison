import Foundation
import Models

extension Report.Battery {
  public init(
    batteryStdout: String?,
    powerSettingsStdout: String?
  ) throws {
    guard let batteryStdout else { throw Report.Failure.stdout(batteryStdout) }

    let noInternalBattery = "No internal battery detected"
    let unavailable = "Unavailable"

    if batteryStdout.localizedCaseInsensitiveContains("no batteries") {
      self.init(
        batteryPercentage: noInternalBattery,
        isCharging: noInternalBattery,
        isLowPowerModeOnBatteryEnabled: noInternalBattery,
        isLowPowerModeOnAcEnabled: Self.lowPowerMode(
          in: powerSettingsStdout,
          systemProfilerRegex: .batteryAcPowerLowPowerMode,
          pmsetRegex: .batteryAcPowerLowPowerModePmset
        ) ?? unavailable
      )
      return
    }
    
    self.init(
      batteryPercentage: batteryStdout.firstMatch(of: .batteryStateOfChargePmset)?.value()
        ?? batteryStdout.firstMatch(of: .batteryStateOfCharge)?.value()
        ?? unavailable,
      isCharging: Self.chargingState(in: batteryStdout) ?? unavailable,
      isLowPowerModeOnBatteryEnabled: Self.lowPowerMode(
        in: powerSettingsStdout,
        systemProfilerRegex: .batteryBatteryPowerLowPowerMode,
        pmsetRegex: .batteryBatteryPowerLowPowerModePmset
      ) ?? unavailable,
      isLowPowerModeOnAcEnabled: Self.lowPowerMode(
        in: powerSettingsStdout,
        systemProfilerRegex: .batteryAcPowerLowPowerMode,
        pmsetRegex: .batteryAcPowerLowPowerModePmset
      ) ?? unavailable
    )
  }

  private static func chargingState(in stdout: String) -> String? {
    if let value = stdout.firstMatch(of: .batteryCharging)?.value() {
      return value
    }

    guard let status = stdout.firstMatch(of: .batteryChargingPmset)?.value()?.lowercased() else {
      return nil
    }

    switch status {
    case "charging", "charged", "finishing charge":
      return "Yes"
    case "discharging":
      return "No"
    default:
      return status.capitalized
    }
  }

  private static func lowPowerMode(
    in stdout: String?,
    systemProfilerRegex: AnyRegex,
    pmsetRegex: AnyRegex
  ) -> String? {
    guard let stdout else { return nil }

    if let value = stdout.firstMatch(of: systemProfilerRegex)?.value() {
      return value
    }

    switch stdout.firstMatch(of: pmsetRegex)?.value() {
    case "1":
      return "Yes"
    case "0":
      return "No"
    default:
      return nil
    }
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

extension Report.Xcodebuild {
  public init(stdout: String?) {
    let notAvailable = "Not available"
    self.init(
      version: stdout?.firstMatch(of: .xcodeVersion)?.value() ?? notAvailable,
      buildVersion: stdout?.firstMatch(of: .xcodeBuildVersion)?.value() ?? notAvailable
    )
  }
}
