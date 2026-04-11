import Testing

@Suite
@MainActor
struct BarTests {
  @Test
  func `test Bar one`() async throws {
    try await confirmation { confirm in
      try await Task.sleep(for: .seconds(1))
      confirm()
    }
  }
}
