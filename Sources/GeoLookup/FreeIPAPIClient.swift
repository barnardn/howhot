import APINetworking
import Foundation

#if os(Linux)
    import FoundationNetworking
#else
    import Network
#endif

final public class FreeIPAPIClient: LocationInfoClient {
    private let host = "free.freeipapi.com"
    public let apiProvider: APIProvider

	public func queryURL(ipAddress: String) -> String {
		return "https://\(host)/api/json/\(ipAddress)"
	}

    public init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    public func geoLocation(ipAddress: String) async throws -> LocationInfo {
    	let queryURL = queryURL(ipAddress: ipAddress)
        guard let url = URL(string: queryURL) else { throw ApiError.badURL(queryURL) }
        let response = try await apiProvider.apiResponse(IPGeolocation.self, request: URLRequest(url: url))
        return response.payload.toLocationInfo()
    }
}
