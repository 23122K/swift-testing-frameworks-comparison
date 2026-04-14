import XCTest

final class BarXCTests: XCTestCase {
  func testBarOne() async throws {
    try await Task.sleep(for: .seconds(1))
  }
}
