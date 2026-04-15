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

    let resultsPath = self.storage
      .directory()
      .appending(path: "xcodebuild")
    print("Results: \(resultsPath.path())")
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
