import Testing

@Suite
struct BazTests {
  @Test
  func `test Baz one`() async throws {
    try await Task.sleep(for: .seconds(2))
  }

  @Test
  func `test Baz two`() async throws {
    try await Task.sleep(for: .seconds(2))
  }
}
