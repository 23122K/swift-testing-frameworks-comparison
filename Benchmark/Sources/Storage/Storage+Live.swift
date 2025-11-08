import Dependencies
import Foundation
import Synchronization

extension Storage: DependencyKey {
  public static let liveValue: Storage = {
    let mutex = Mutex<FileManager>(FileManager.default)
    let directory = mutex.withLock { fileManager in
      fileManager.temporaryDirectory.appending(path: "com.23122K.TestBenchmark")
    }
    
    return Storage(
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
