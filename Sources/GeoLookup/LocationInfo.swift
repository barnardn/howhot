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

public protocol SupportsLocationInfo {
	func toLocationInfo() -> LocationInfo
}

public protocol LocationInfoClient {
	var apiProvider: APIProvider { get }
	func queryURL(ipAddress: String) -> String
	func geoLocation(ipAddress: String) async throws -> LocationInfo
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
