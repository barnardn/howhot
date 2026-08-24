import APINetworking
import Foundation

#if os(Linux)
    import FoundationNetworking
#else
    import Network
#endif

final public class GeolocatedIOClient: LocationInfoClient {
    private let host = "us-west-1.geolocated.io"
    private let apiKey: String

    public let apiProvider: APIProvider

    public init(apiKey: String, apiProvider: APIProvider) {
        self.apiKey = apiKey
        self.apiProvider = apiProvider
    }

    public func queryURL(ipAddress: String) -> String {
        "https://\(host)/ip/\(ipAddress)?api-key=\(apiKey)"
    }

    public func geoLocation(ipAddress: String) async throws -> LocationInfo {
        let queryURL = queryURL(ipAddress: ipAddress)
        guard let url = URL(string: queryURL) else { throw ApiError.badURL(queryURL) }
        let response = try await apiProvider.apiResponse(StandardLookupResponse.self, request: URLRequest(url: url))
        return response.payload.toLocationInfo()
    }
}
