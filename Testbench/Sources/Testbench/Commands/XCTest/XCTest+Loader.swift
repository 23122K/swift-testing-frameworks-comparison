import Foundation

actor Loader {
  private struct CompletedBundle {
    let scheme: String
    let bundleName: String
    let framework: String
    let total: Int
    let averageRuntime: Double
  }

  private enum ANSI {
    static let bold = "\u{001B}[1m"
    static let dim = "\u{001B}[2m"
    static let green = "\u{001B}[32m"
    static let reset = "\u{001B}[0m"
  }

  private let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  private var frameIndex = 0
  private var previousLineCount = 0
  private var isActive = false
  private var isRunningIteration = false

  private var currentScheme = ""
  private var currentBundleName = ""
  private var framework: String? = nil
  private var iteration = 0
  private var total = 0
  private var runtime: Double = 0
  private var queued: [(scheme: String, bundle: URL)] = []
  private var currentBundleRuntimes: [Double] = []
  private var completedBundles: [CompletedBundle] = []

  func start(
    scheme: String,
    bundleName: String,
    iteration: Int,
    total: Int,
    queued: [(scheme: String, bundle: URL)]
  ) {
    self.currentScheme = scheme
    self.currentBundleName = bundleName
    self.framework = nil
    self.iteration = iteration
    self.total = total
    self.runtime = 0
    self.queued = queued
    self.currentBundleRuntimes = []
    self.isActive = true
    self.isRunningIteration = true
    redraw()
  }

  func beginIteration(_ iteration: Int) {
    guard isActive else { return }
    self.iteration = iteration
    self.isRunningIteration = true
    redraw()
  }

  func finish(framework: String, iteration: Int, runtime: Double) {
    self.framework = framework
    self.iteration = iteration
    self.runtime = runtime
    self.currentBundleRuntimes.append(runtime)
    self.isRunningIteration = false
  }

  func tick() {
    guard isActive, isRunningIteration else { return }
    frameIndex += 1
    redraw()
  }

  func complete(scheme: String, bundleName: String, framework: String, total: Int) {
    isActive = false
    isRunningIteration = false

    let averageRuntime =
      currentBundleRuntimes.isEmpty
      ? 0
      : currentBundleRuntimes.reduce(0, +) / Double(currentBundleRuntimes.count)

    completedBundles.append(
      CompletedBundle(
        scheme: scheme,
        bundleName: bundleName,
        framework: framework,
        total: total,
        averageRuntime: averageRuntime
      )
    )
    redraw()
  }

  func finishOutput() {
    guard previousLineCount > 0 else { return }
    write("\n")
    previousLineCount = 0
  }

  private func redraw() {
    clearPreviousLines()

    let spinner = frames[frameIndex % frames.count]
    var lines: [String] = []
    var lastScheme: String? = nil

    for bundle in completedBundles {
      if bundle.scheme != lastScheme {
        lines.append(styledScheme(bundle.scheme))
        lastScheme = bundle.scheme
      }
      var line = " \(ANSI.green)✓\(ANSI.reset) \(bundle.scheme)/\(bundle.bundleName) \(bundle.total)/\(bundle.total) \(bundle.framework)"
      if bundle.averageRuntime > 0 {
        line += " \(String(format: "%.3f", bundle.averageRuntime))s (Average time)"
      }
      lines.append(line)
    }

    if isActive {
      if currentScheme != lastScheme {
        lines.append(styledScheme(currentScheme))
        lastScheme = currentScheme
      }

      var current = "  \(spinner) \(currentBundleName) \(iteration)/\(total)"
      if let framework {
        current += " \(framework)"
      }
      if runtime > 0 {
        current += " \(String(format: "%.3f", runtime))s"
      }
      current += " (Total time)"
      lines.append(current)
    }

    for item in queued {
      if item.scheme != lastScheme {
        lines.append(styledScheme(item.scheme, dimmed: true))
        lastScheme = item.scheme
      }
      lines.append("\(ANSI.dim)  ↳ \(item.bundle.lastPathComponent)\(ANSI.reset)")
    }

    write(lines.joined(separator: "\n"))
    previousLineCount = lines.count
  }

  private func clearPreviousLines() {
    guard previousLineCount > 0 else { return }
    write("\r\u{1B}[2K")
    for _ in 1..<previousLineCount {
      write("\u{1B}[A\r\u{1B}[2K")
    }
  }

  private func write(_ string: String) {
    FileHandle.standardOutput.write(Data(string.utf8))
  }

  private func styledScheme(_ scheme: String, dimmed: Bool = false) -> String {
    let prefix = dimmed ? "\(ANSI.dim)\(ANSI.bold)" : ANSI.bold
    return "\(prefix)\(scheme)\(ANSI.reset)"
  }
}
