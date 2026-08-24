import Common
import Foundation

public struct IPGeolocation: Codable {
    let ipVersion: Int
    let ipAddress: String
    let latitude: Double
    let longitude: Double
    let countryName: String
    let countryCode: String
    let capital: String
    let phoneCodes: [Int]
    let timeZones: [String]
    let zipCode: String
    let cityName: String
    let regionName: String
    let regionCode: String
    let continent: String
    let continentCode: String
    let currencies: [String]
    let languages: [String]
    let asn: String
    let asnOrganization: String
    let isProxy: Bool
}

extension IPGeolocation: SupportsLocationInfo {
    public func toLocationInfo() -> LocationInfo {
        LocationInfo(
            ip: ipAddress,
            countryCode: countryCode,
            countryName: countryName,
            regionName: regionName,
            regionCode: regionCode,
            cityName: cityName,
            coordinates: Coordinates(latitude: latitude, longitude: longitude),
            zipCode: zipCode,
            timeZone: nil
        )
    }
}

extension IPGeolocation: CustomStringConvertible {
    public var description: String {
        """
        IP Version: \(ipVersion)
        IP Address: \(ipAddress)
        Location: \(latitude), \(longitude)
        Country Name: \(countryName)
        Country Code: \(countryCode)
        Capital: \(capital)
        Zip Code: \(zipCode)
        City Name: \(cityName)
        Region Name: \(regionName)
        Region Code: \(regionCode)
        Continent: \(continent)
        Continent Code: \(continentCode)
        ASN: \(asn)
        ASN Organization: \(asnOrganization)
        Is Proxy: \(isProxy)
        """
    }
}
