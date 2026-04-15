import XCTest

final class BazXCTests: XCTestCase {
  func testBazOne() async throws {
    try await Task.sleep(for: .seconds(2))
  }

  func testBazTwo() async throws {
    try await Task.sleep(for: .seconds(2))
  }
}
