import Foundation
import Synchronization

public struct FileManagerClient: Sendable {
  var _write: @Sendable (any Encodable, String, JSONEncoder) throws -> Bool
  var _decode: @Sendable (String) throws -> Data?
  public var contents: @Sendable (URL) throws -> Data
  public var directory: @Sendable () -> URL
  
  public enum Failure: Sendable, Error {
    case noFileContentAtPath(URL)
  }
}

extension FileManagerClient {
  public static let shared: FileManagerClient = {
    let mutex = Mutex<FileManager>(FileManager.default)
    let directory = mutex.withLock { fileManager in
      fileManager.temporaryDirectory.appending(path: "com.23122K.TestBenchmark")
    }
    
    return FileManagerClient(
      _write: { content, path, encoder in
        try mutex.withLock { fileManager in
          var directoryExists: ObjCBool = false
          fileManager.fileExists(
            atPath: directory.path(),
            isDirectory: &directoryExists
          )
          
          if !directoryExists.boolValue {
            try fileManager.createDirectory(
              at: directory,
              withIntermediateDirectories: false
            )
          }
        }
      
        return try mutex.withLock { fileManager in
          try fileManager.createFile(
            atPath: directory.appending(path: path).path(),
            contents: encoder.encode(content)
          )
        }
      },
      _decode: { path in
        mutex.withLock { fileManager in
          fileManager.contents(
            atPath: directory.appending(path: path).path()
          )
        }
      },
      contents: { url in
        try mutex.withLock { fileManager in
          guard let data = fileManager.contents(atPath: url.path())
          else { throw Failure.noFileContentAtPath(url) }
          return data
        }
      },
      directory: {
        directory
      }
    )
  }()
}

extension FileManagerClient {
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
  ) throws -> T? {
    guard let data = try self._decode(name)
    else { return nil }
    return try decoder.decode(type, from: data)
  }
}
