import ArgumentParser
import Common
import Configuration
import Foundation
import GeoLookup
import SystemPackage

struct GeocodeCommand: AsyncParsableCommand {
    @OptionGroup var appOptions: AppOptions

    static let configuration = CommandConfiguration(
        commandName: "geocode",
        abstract: "Determine location via IP address lookup"
    )

    @Argument(help: "The ip address to geocode")
    var address: String

    mutating func run() async throws {
        // let environmentProvider = EnvironmentVariablesProvider().prefixKeys(with: "howhot")
        // let configURL: URL
        // let configFile = appOptions.configFile ?? AppConstants.defaultConfigFile
        // configURL = URL(fileURLWithPath: configFile)
        // let path = FilePath(stringLiteral: configURL.path())

        // let config = try ConfigReader(providers: [
        //     // prefer values from environment..
        //     environmentProvider,
        //     // fall back to configuration file
        //     await FileProvider<YAMLSnapshot>(filePath: path, allowMissing: true),
        // ])
        let config = try await AppConfig.configReader()
        guard let apiKey = config.string(forKey: "geokey") else {
            throw AppError.missingApiKey("Geolocated.io")
        }
        let client = GeolocatedIOClient(apiKey: apiKey, apiProvider: .default)
        let locationInfo = try await client.geoLocation(ipAddress: address)
        print(locationInfo.description)
    }
}
