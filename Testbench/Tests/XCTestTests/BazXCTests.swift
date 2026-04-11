import XCTest

final class BazXCTests: XCTestCase {
  func testBazOne() async throws {
    let expectation = XCTestExpectation()
    try await Task.sleep(for: .seconds(2))
    expectation.fulfill()
    
    await fulfillment(of: [expectation])
  }
  
  func testBazTwo() async throws {
    let expectation = XCTestExpectation()
    try await Task.sleep(for: .seconds(2))
    expectation.fulfill()
    
    await fulfillment(of: [expectation])
  }
}
