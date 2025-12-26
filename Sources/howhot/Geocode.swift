import ArgumentParser
import Common
import Configuration
import Foundation
import GeoLookup
import IPAddressLookup

struct GeocodeCommand: AsyncParsableCommand {
    @OptionGroup var appOptions: AppOptions

    static let configuration = CommandConfiguration(
        commandName: "geocode",
        abstract: "Determine location via IP address lookup"
    )

    @Option(help: "The ip address to geocode. Defaults to current ip address.")
    var address: String?

    @Flag(name: .shortAndLong, help: "Returns just the zip code")
    var zipOnly = false

    mutating func run() async throws {
        let config = try await AppConfig.configReader(configPath: appOptions.configFile)
        guard let apiKey = config.string(forKey: "geokey") else {
            throw AppError.missingApiKey("geokey")
        }
        let ipAddress: String
        if let address {
            ipAddress = address
        } else {
            let ipClient = AmazonClient(apiProvider: .default)
            ipAddress = try await ipClient.fetchIPAddress()
        }
        let geoClient = GeolocatedIOClient(apiKey: apiKey, apiProvider: .default)
        let locationInfo = try await geoClient.geoLocation(ipAddress: ipAddress)
        if zipOnly {
            print(locationInfo.zipCode)
        } else {
            print(locationInfo.description)
        }
    }
}
