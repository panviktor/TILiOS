import Foundation

struct AcronymRequest {
  let resource: URL
  init(acronymID: UUID) {
    let resourceString =
      "http://localhost:8080/api/acronyms/\(acronymID)"
    guard let resourceURL = URL(string: resourceString) else {
      fatalError("Unable to createURL")
    }
    self.resource = resourceURL
  }
  
  func getUser(completion: @escaping (Result<User, ResourceRequestError>) -> Void) {
    let url = resource.appendingPathComponent("user")
    let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
      guard let jsonData = data else {
        completion(.failure(.noData))
        return
      }
      do {
        let user = try JSONDecoder()
          .decode(User.self, from: jsonData)
        completion(.success(user))
      } catch {
        completion(.failure(.decodingError))
      }
    }
    dataTask.resume()
  }
  
  
  func getCategories(completion: @escaping (Result<[Category], ResourceRequestError>) -> Void ){
    let url = resource.appendingPathComponent("categories")
    let dataTask = URLSession.shared
      .dataTask(with: url) { data, _, _ in
        guard let jsonData = data else {
          completion(.failure(.noData))
          return
        }
        do {
          let categories = try JSONDecoder()
            .decode([Category].self, from: jsonData)
          completion(.success(categories))
        } catch {
          completion(.failure(.decodingError))
        }
      }
    dataTask.resume()
  }
  
}

