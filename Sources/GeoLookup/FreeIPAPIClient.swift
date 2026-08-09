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
		return "https://\(host)/api/json/\(ipAddress))"
	}

    public init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
}
