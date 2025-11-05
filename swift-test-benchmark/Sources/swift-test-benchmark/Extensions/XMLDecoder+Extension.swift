@preconcurrency import XMLCoder

extension XMLDecoder {
  public static let xunit: XMLDecoder = {
    let decoder = XMLDecoder()
    decoder.trimValueWhitespaces = true
    decoder.shouldProcessNamespaces = false
    return decoder
  }()
}
