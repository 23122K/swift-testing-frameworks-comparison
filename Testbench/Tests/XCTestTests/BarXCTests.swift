import XCTest

final class BarXCTests: XCTestCase {
  func testBarOne() async throws {
    let expectation = XCTestExpectation()
    try await Task.sleep(for: .seconds(1))
    expectation.fulfill()
    
    await fulfillment(of: [expectation])
  }
}
