import XCTest

final class FooXCTests: XCTestCase {
  func testFooOne() async throws {
    try await Task.sleep(for: .seconds(5))
  }
}
