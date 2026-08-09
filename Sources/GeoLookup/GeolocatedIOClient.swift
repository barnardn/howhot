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
    	return "https://\(host)/ip/\(ipAddress)?api-key=\(apiKey)"
    }    
}


