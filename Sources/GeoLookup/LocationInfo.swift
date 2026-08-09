import APINetworking
import Common
import Foundation

public struct LocationInfo: Codable {
    public let ip: String
    public let countryCode: String
    public let countryName: String
    public let regionName: String
    public let regionCode: String
    public let cityName: String
    public let coordinates: Coordinates
    public let zipCode: String
    public let timeZone: String?
}

protocol SupportsLocationInfo {
	func toLocationInfo() -> LocationInfo
}

public protocol LocationInfoClient {
	var apiProvider: APIProvider { get }
	func queryURL(ipAddress: String) -> String
	func geoLocation(ipAddress: String) async throws -> LocationInfo
}

public extension LocationInfoClient {
    func geoLocation(ipAddress: String) async throws -> LocationInfo {
    	let queryURL = queryURL(ipAddress: ipAddress)
        guard let url = URL(string: queryURL) else { throw ApiError.badURL(queryURL) }
        let response = try await apiProvider.apiResponse(StandardLookupResponse.self, request: URLRequest(url: url))
        return response.payload.toLocationInfo()
    }
}


extension LocationInfo: CustomStringConvertible {
    public var description: String {
        """
        IP Address: \(ip)
        Country: \(countryName)
        State: \(regionName)
        City: \(cityName)
        Timezone: \(timeZone ?? "")
        Zip code: \(zipCode)
        Coordinates: \(coordinates.description)
        """
    }
}
