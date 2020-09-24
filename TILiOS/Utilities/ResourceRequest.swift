import Foundation

struct ResourceRequest<ResourceType> where ResourceType: Codable {
  let baseURL = "http://localhost:8080/api"
  let resourceURL: URL
  
  init(resourcePath: String) {
    guard let resourceURL = URL(string: baseURL) else {
      fatalError("Failed to conver baseURL to a URL")
    }
    self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
  }
}
