import Common
import Foundation

struct StandardLookupResponse: Codable {
    let ip: String
    let version: String
    let addressType: String
    let continentCode: String
    let continentName: String
    let countryCode: String
    let countryName: String
    let regionName: String
    let regionCode: String
    let cityName: String
    let latitude: Double
    let longitude: Double
    let zipCode: String
    let timeZone: String
    let iddCode: String

    enum CodingKeys: String, CodingKey {
        case ip
        case version
        case addressType
        case continentCode
        case continentName
        case countryCode
        case countryName
        case regionName
        case regionCode
        case cityName
        case latitude
        case longitude
        case zipCode
        case timeZone
        case iddCode
    }
}

extension StandardLookupResponse: SupportsLocationInfo {
    func toLocationInfo() -> LocationInfo {
        LocationInfo(
            ip: ip, countryCode: countryCode, countryName: countryName, regionName: regionName, regionCode: regionCode,
            cityName: cityName, coordinates: Coordinates(latitude: latitude, longitude: longitude), zipCode: zipCode,
            timeZone: timeZone
        )
    }
}
