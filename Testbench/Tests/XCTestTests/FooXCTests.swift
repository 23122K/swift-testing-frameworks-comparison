import XCTest

final class FooXCTests: XCTestCase {
  func testFooOne() async throws {
    let expectation = XCTestExpectation()
    try await Task.sleep(for: .seconds(5))
    expectation.fulfill()
    
    await fulfillment(of: [expectation])
  }
}
