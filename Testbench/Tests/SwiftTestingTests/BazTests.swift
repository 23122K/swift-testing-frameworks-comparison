import Testing

@Suite
struct BazTests {
  @Test
  func `test Baz one`() async throws {
    try await confirmation { confirm in
      try await Task.sleep(for: .seconds(2))
      confirm()
    }
  }
  
  @Test
  func `test Baz two`() async throws {
    try await confirmation { confirm in
      try await Task.sleep(for: .seconds(2))
      confirm()
    }
  }
}
