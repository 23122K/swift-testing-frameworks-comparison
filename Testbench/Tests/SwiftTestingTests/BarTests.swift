import Testing

@Suite
struct BarTests {
  @Test
  func `test Bar one`() async throws {
    try await Task.sleep(for: .seconds(1))
  }
}
