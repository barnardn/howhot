import ArgumentParser
import Common
import Configuration
import Foundation
import GeoLookup
import IPAddressLookup

enum OutputMode: String, EnumerableFlag {
    case zipcode
    case gps
    case full
}

struct GeocodeCommand: AsyncParsableCommand {
    @OptionGroup var appOptions: AppOptions

    static let configuration = CommandConfiguration(
        commandName: "geocode", abstract: "Determine location via IP address lookup"
    )

    @Option(help: "The ip address to geocode. Defaults to current ip address.") var address: String?

    @Flag(exclusivity: .exclusive, help: "Output mode") var outputMode: OutputMode = .full

    mutating func run() async throws {
        let config = try await AppConfig.configReader(configPath: appOptions.configFile)
        guard config.string(forKey: "geokey") != nil else { throw AppError.missingApiKey("geokey") }
        let ipAddress: String
        if let address {
            ipAddress = address
        } else {
            let ipClient = AmazonClient(apiProvider: .default)
            ipAddress = try await ipClient.fetchIPAddress()
        }
        let geoClient = FreeIPAPIClient(apiProvider: .default)
        let locationInfo = try await geoClient.geoLocation(ipAddress: ipAddress)

        let output = switch outputMode {
        case .gps:
            "\(locationInfo.coordinates)"
        case .zipcode:
            "\(locationInfo.zipCode ?? "null")"
        default:
            locationInfo.description
        }
        print(output)
    }
}
