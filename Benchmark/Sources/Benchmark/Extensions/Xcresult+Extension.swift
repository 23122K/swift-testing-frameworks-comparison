import Foundation
import Storage
import Models

extension Xcresult {
  public init(
    at url: URL,
    decoder: JSONDecoder = JSONDecoder(),
    data: (URL) throws -> Data = { url in try Storage.live.contents(url) }
  ) throws {
    let data = Data(base64Encoded: try data(url))!
    let decoded = try decoder.decode(Self.self, from: data)
    
    self.init(
      devices: decoded.devices,
      testNodes: decoded.testNodes,
      testPlanConfigurations: decoded.testPlanConfigurations
    )
  }
}
