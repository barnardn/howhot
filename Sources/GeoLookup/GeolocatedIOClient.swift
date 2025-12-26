import APINetworking
import Foundation

final public class GeolocatedIOClient {
    private let host = "us-west-1.geolocated.io"
    private let apiKey: String
    private let apiProvider: APIProvider

    public init(apiKey: String, apiProvider: APIProvider) {
        self.apiKey = apiKey
        self.apiProvider = apiProvider
    }

    public func geoLocation(ipAddress: String) async throws -> LocationInfo {
        let path = "ip/\(ipAddress)?api-key=\(apiKey)"
        let urlString = "https://\(host)/\(path)"

        guard let url = URL(string: urlString) else {
            throw ApiError.badURL(urlString)
        }
        let response = try await apiProvider.apiResponse(StandardLookupResponse.self, request: URLRequest(url: url))
        return response.payload.toLocationInfo()
    }
}
