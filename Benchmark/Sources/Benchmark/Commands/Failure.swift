import Foundation

struct Failure: LocalizedError, Equatable {
  let code: UInt8
  let errorDescription: String?
  
  init(
    code: UInt8,
    errorDescription: String? = nil
  ) {
    self.code = code
    self.errorDescription = errorDescription
  }
}
