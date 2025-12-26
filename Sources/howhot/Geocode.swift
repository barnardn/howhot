import ArgumentParser
import Common
import Configuration
import Foundation
import GeoLookup

struct GeocodeCommand: AsyncParsableCommand {
    @OptionGroup var appOptions: AppOptions

    static let configuration = CommandConfiguration(
        commandName: "geocode",
        abstract: "Determine location via IP address lookup"
    )

    @Argument(help: "The ip address to geocode")
    var address: String

    mutating func run() async throws {
        let config = try await AppConfig.configReader(configPath: appOptions.configFile)
        guard let apiKey = config.string(forKey: "geokey") else {
            throw AppError.missingApiKey("geokey")
        }
        let client = GeolocatedIOClient(apiKey: apiKey, apiProvider: .default)
        let locationInfo = try await client.geoLocation(ipAddress: address)
        print(locationInfo.description)
    }
}
