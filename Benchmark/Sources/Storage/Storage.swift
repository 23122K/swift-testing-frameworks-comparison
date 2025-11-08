import Foundation
import Synchronization

public struct Storage: Sendable {
  var _write: @Sendable (any Encodable, String, JSONEncoder) throws -> Bool
  var _decode: @Sendable (String) throws -> Data?
  public var contents: @Sendable (URL) throws -> Data
  public var directory: @Sendable () -> URL
}

extension Storage {
  @discardableResult
  public func write(
    _ content: some Encodable,
    name: String,
    encoder: JSONEncoder = JSONEncoder()
  ) throws -> Bool {
    try self._write(content, name, encoder)
  }
  
  public func decode<T: Decodable>(
    name: String,
    decoder: JSONDecoder = JSONDecoder(),
    as type: T.Type = T.self
  ) throws -> T {
    guard let data = try self._decode(name) else {
      throw Failure.noFileContentAtPath(
        self.directory()
          .appending(path: name)
      )
    }
    return try decoder.decode(type, from: data)
  }
}

extension Storage {
  public enum Failure: Sendable, Error {
    case noFileContentAtPath(URL)
  }
}
