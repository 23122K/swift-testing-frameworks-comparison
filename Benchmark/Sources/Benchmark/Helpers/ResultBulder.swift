@resultBuilder
struct ResultBuilder<T> {
  static func buildBlock(_ components: [T]...) -> [T] {
    components.flatMap(\.self)
  }
  
  static func buildExpression(_ expression: T) -> [T] {
    [expression]
  }
  
  static func buildExpression(_ expression: [T]) -> [T] {
    expression
  }

  static func buildOptional(_ components: [T]?) -> [T] {
    components ?? []
  }
  
  static func buildEither(first components: [T]) -> [T] {
    components
  }
  
  static func buildEither(second components: [T]) -> [T] {
    components
  }
}
