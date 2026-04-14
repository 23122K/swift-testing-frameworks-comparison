import Testing

@Suite
@MainActor
struct FooTests {
  @Test
  func `test Foo one`() async throws {
    try await Task.sleep(for: .seconds(5))
  }
}
