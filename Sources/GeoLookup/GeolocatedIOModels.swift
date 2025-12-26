import Foundation

public struct Coordinates: Codable {
    public let latitude: Float
    public let longitude: Float
}

extension Coordinates: CustomStringConvertible {
    public var description: String {
        return String(format: "Lat: %.8f, Lon: %.8f", latitude, longitude)
    }
}

public struct LocationInfo: Codable {
    public let ip: String
    public let countryCode: String
    public let countryName: String
    public let regionName: String
    public let regionCode: String
    public let cityName: String
    public let district: String
    public let coordinates: Coordinates
    public let zipCode: String
    public let timeZone: String
}

extension LocationInfo: CustomStringConvertible {
    public var description: String {
        return """
        IP Address: \(ip)
        Country: \(countryName)
        State: \(regionName)
        City: \(cityName)
        Timezone: \(timeZone)
        Zip code: \(zipCode)
        Coordinates: \(coordinates.description)
        """
    }
}

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
    let district: String
    let latitude: Float
    let longitude: Float
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
        case district
        case latitude
        case longitude
        case zipCode
        case timeZone
        case iddCode
    }

    func toLocationInfo() -> LocationInfo {
        return LocationInfo(
            ip: ip,
            countryCode: countryCode,
            countryName: countryName,
            regionName: regionName,
            regionCode: regionCode,
            cityName: cityName,
            district: district,
            coordinates: Coordinates(latitude: latitude, longitude: longitude),
            zipCode: zipCode,
            timeZone: timeZone
        )
    }
}
