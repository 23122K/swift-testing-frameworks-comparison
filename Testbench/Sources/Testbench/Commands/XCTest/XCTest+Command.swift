import ArgumentParser
import Factory
import DefaultsClient
import StorageClient
import Foundation
import Models

struct XCTestCommand: AsyncParsableCommand {
  @OptionGroup
  var common: CommonOptions

  @Flag(
    name: [.customLong("force"), .customShort("f")],
    help: "Purge any existing results without prompting."
  )
  var force: Bool = false

  @Option(
    name: [.customShort("i")],
    help: "Number of iterations per test bundle."
  )
  var iterations: Int = 100

  @Flag(
    name: [.customLong("list"), .customShort("l")],
    help: "List all available artifacts without running them."
  )
  var list: Bool = false

  mutating func run() async throws {
    guard let repoPath: String = try self.defaults.get(forKey: .repositoryURL) else {
      print("Repository path not set. Run: testbench --set-path <PATH>")
      return
    }
    let repositoryURL = URL(filePath: repoPath, directoryHint: .isDirectory)
    let artifactsURL = repositoryURL.appending(path: "Artifacts")
    let bundles = try self.findArtifacts(in: artifactsURL)

    if self.list {
      self.printArtifacts(bundles, in: artifactsURL)
      return
    }

    try self.checkAndPurgeExistingResults()

    guard !bundles.isEmpty else {
      print("No artifacts found in \(artifactsURL.path())")
      print("Build artifacts first with: testbench xcodebuild <scheme>")
      return
    }

    try await generateReportSequentially()
    try await self.runAllBundles(bundles)
    let exportedResultsURL = try self.exportResults(to: repositoryURL, bundles: bundles)

    let resultsPath = self.storage
      .directory()
      .appending(path: "xcodebuild")
    print("Results: \(resultsPath.path())")
    print("Copied to: \(exportedResultsURL.path())")
  }

  private func printArtifacts(_ bundles: [(scheme: String, bundle: URL)], in artifactsURL: URL) {
    guard !bundles.isEmpty else {
      print("No artifacts found in \(artifactsURL.path())")
      print("Build artifacts first with: testbench xcodebuild <scheme>")
      return
    }

    var currentScheme: String? = nil
    for (scheme, bundle) in bundles {
      if scheme != currentScheme {
        print(scheme)
        currentScheme = scheme
      }
      print("  \(bundle.lastPathComponent)")
    }
  }

  // MARK: - Artifact discovery

  func findArtifacts(in artifactsURL: URL) throws -> [(scheme: String, bundle: URL)] {
    let schemeNames: [String]
    do {
      schemeNames = try self.storage.contentsOfDirectory(artifactsURL)
    } catch {
      return []
    }

    var result: [(scheme: String, bundle: URL)] = []
    for schemeName in schemeNames.sorted() {
      let schemeDir = artifactsURL.appending(path: schemeName)
      guard self.storage.isDirectory(schemeDir) else { continue }

      let bundles = (try? self.storage.contentsOfDirectory(schemeDir)) ?? []
      for bundleName in bundles.filter({ $0.hasSuffix(".xctest") }).sorted() {
        result.append((scheme: schemeName, bundle: schemeDir.appending(path: bundleName)))
      }
    }
    return result
  }

  // MARK: - Results guard

  private func checkAndPurgeExistingResults() throws {
    let resultsDir = self.storage
      .directory()
      .appending(path: "xcodebuild")

    let contents: [String]
    do {
      contents = try self.storage.contentsOfDirectory(resultsDir)
    } catch {
      return
    }

    guard !contents.isEmpty else { return }

    guard self.force else {
      throw XCTestError.resultsAlreadyExist(path: resultsDir.path())
    }

    try self.storage.delete(resultsDir)
    print("Existing results purged (--force).")
  }

  // MARK: - Export

  private func exportResults(
    to repositoryURL: URL,
    bundles: [(scheme: String, bundle: URL)]
  ) throws -> URL {
    let hardware: Report.Hardware = try self.storage.decode(name: "hardware.json")
    let resultsRoot = repositoryURL.appending(path: "Results")
    try self.storage.createDirectory(resultsRoot)

    let deviceRoot = resultsRoot.appending(path: self.deviceResultsDirectoryName(from: hardware))
    try? self.storage.delete(deviceRoot)
    try self.storage.createDirectory(deviceRoot)

    let reportDirectory = deviceRoot.appending(path: "Report")
    try self.storage.createDirectory(reportDirectory)

    let storageDirectory = self.storage.directory()
    let reportFiles = [
      "battery.json",
      "hardware.json",
      "swift.json",
      "system.json",
      "xcodebuild.json"
    ]

    for name in reportFiles {
      let source = storageDirectory.appending(path: name)
      let destination = reportDirectory.appending(path: name)
      guard let data = try? self.storage.contents(source) else { continue }
      try self.storage.writeData(data, destination)
    }

    let bundleNamesBySchemeAndTarget = Dictionary(
      uniqueKeysWithValues: bundles.map { bundle in
        (
          "\(bundle.scheme)::\(bundle.bundle.deletingPathExtension().lastPathComponent)",
          bundle.bundle.lastPathComponent
        )
      }
    )

    let xcodebuildSource = storageDirectory.appending(path: "xcodebuild")
    if self.storage.isDirectory(xcodebuildSource) {
      try self.exportIterations(
        from: xcodebuildSource,
        to: deviceRoot,
        bundleNamesBySchemeAndTarget: bundleNamesBySchemeAndTarget
      )
    }

    return deviceRoot
  }

  private func exportIterations(
    from sourceRoot: URL,
    to destinationRoot: URL,
    bundleNamesBySchemeAndTarget: [String: String]
  ) throws {
    for scheme in try self.storage.contentsOfDirectory(sourceRoot).sorted() {
      let schemeSource = sourceRoot.appending(path: scheme)
      guard self.storage.isDirectory(schemeSource) else { continue }

      let schemeDestination = destinationRoot.appending(path: scheme)
      try self.storage.createDirectory(schemeDestination)

      for target in try self.storage.contentsOfDirectory(schemeSource).sorted() {
        let targetSource = schemeSource.appending(path: target)
        guard self.storage.isDirectory(targetSource) else { continue }

        let lookupKey = "\(scheme)::\(target)"
        let bundleName = bundleNamesBySchemeAndTarget[lookupKey] ?? target
        let iterationsDestination = schemeDestination
          .appending(path: bundleName)
          .appending(path: "iterations")
        try self.storage.createDirectory(iterationsDestination)

        for entry in try self.storage.contentsOfDirectory(targetSource).sorted() {
          let source = targetSource.appending(path: entry)
          guard !self.storage.isDirectory(source) else { continue }
          let destination = iterationsDestination.appending(path: entry)
          let data = try self.storage.contents(source)
          try self.storage.writeData(data, destination)
        }
      }
    }
  }

  private func deviceResultsDirectoryName(from hardware: Report.Hardware) -> String {
    self.sanitizePathComponent(
      [
        hardware.modelIdentifier,
        hardware.chip,
        hardware.memory,
        hardware.modelNumber
      ].joined(separator: "__")
    )
  }

  private func sanitizePathComponent(_ value: String) -> String {
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
    let scalars = value.unicodeScalars.map { scalar in
      allowed.contains(scalar) ? Character(scalar) : "-"
    }
    let sanitized = String(scalars)
      .replacingOccurrences(of: "--", with: "-")
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    return sanitized.isEmpty ? "unknown-device" : sanitized
  }
}

extension XCTestCommand {
  var storage: StorageClient {
    @Injected(\.storage) var storage
    return storage
  }

  fileprivate var defaults: DefaultsClient {
    @Injected(\.defaults) var defaults
    return defaults
  }
}

enum XCTestError: Error, CustomStringConvertible {
  case resultsAlreadyExist(path: String)

  var description: String {
    switch self {
    case let .resultsAlreadyExist(path):
      return """
        Results already exist at:
          \(path)
        Re-run with --force / -f to purge existing results and continue.
        """
    }
  }
}
