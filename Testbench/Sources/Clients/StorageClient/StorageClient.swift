import Foundation
import Synchronization

public final class StorageClient: Sendable {
  let _write: @Sendable (any Encodable, String, JSONEncoder) throws -> Bool
  let _decode: @Sendable (String) throws -> Data?
  public let contents: @Sendable (URL) throws -> Data
  public let contentsOfDirectory: @Sendable (URL) throws -> [String]
  public let currentPathDirectry: @Sendable () -> URL
  public let directory: @Sendable () -> URL
  public let delete: @Sendable (URL) throws -> Void
  
  public init(
    _write: @Sendable @escaping (any Encodable, String, JSONEncoder) throws -> Bool,
    _decode: @Sendable @escaping (String) throws -> Data?,
    contents: @Sendable @escaping (URL) throws -> Data,
    contentsOfDirectory: @Sendable @escaping (URL) throws -> [String],
    currentPathDirectry: @Sendable @escaping () -> URL,
    directory: @Sendable @escaping () -> URL,
    delete: @Sendable @escaping (URL) throws -> Void
  ) {
    self._write = _write
    self._decode = _decode
    self.contents = contents
    self.contentsOfDirectory = contentsOfDirectory
    self.currentPathDirectry = currentPathDirectry
    self.directory = directory
    self.delete = delete
  }
}

extension StorageClient {
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

extension StorageClient {
  public enum Failure: Sendable, Error {
    case noFileContentAtPath(URL)
  }
}
