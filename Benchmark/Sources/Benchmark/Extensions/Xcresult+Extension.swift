import Foundation

extension Xcresult {
  public init(
    at url: URL,
    decoder: JSONDecoder = JSONDecoder(),
    data: (URL) throws -> Data = { url in try FileManagerClient.shared.contents(url) }
  ) throws {
    let data = Data(base64Encoded: try data(url))!
    print("1")
    let _self = try decoder.decode(Self.self, from: data)
    self.testPlanConfigurations = _self.testPlanConfigurations
    self.testNodes = _self.testNodes
    self.devices = _self.devices
  }
}
