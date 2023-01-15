import Foundation

struct RestAPIClient<Response: Decodable>: APIClient {
  let session: URLSession = .shared

  func performRequest(url: String) async throws -> Response {
    guard let url = URL(string: url) else { throw APIError.invalidUrl(url) }
    let response: Response = try await perform(request: URLRequest(url: url))
    return response
  }
}
