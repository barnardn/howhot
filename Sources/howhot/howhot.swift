import ArgumentParser
import Common
import Configuration
import ConsoleKit
import Foundation
import GeoLookup
import IPAddressLookup
import OpenWeatherMap
import SystemPackage

struct AppOptions: ParsableArguments {
    static let defaultConfigPath = "~/.config/howhot.yaml"
    @Option(name: .shortAndLong, help: "Alternative configuration file (default: \(defaultConfigPath))")
    var configFile: String?
}

@main
struct howhot: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "howhot",
        abstract: "A command-line tool to check the weather.",
        discussion: "This tool uses the OpenWeatherMap API to retrieve weather information.",
        version: "1.0.0",
        subcommands: [GeocodeCommand.self, IPLookupCommand.self, CurrentConditionsCommand.self]
    )
    @OptionGroup var appOptions: AppOptions

    mutating func run() async throws {
        let config = try await AppConfig.configReader()
        guard
            let geoKey = config.string(forKey: "geokey")
        else {
            throw AppError.missingApiKey("Geolocated.io - defined by geokey")
        }
        guard
            let weatherKey = config.string(forKey: "openweathermap")
        else {
            throw AppError.missingApiKey("Openweathermap.org - defined by openweathermap")
        }
        let terminal = Terminal()
        let loadingBar = terminal.loadingBar(title: "Loading...")
        do {
            try await loadingBar.withActivityIndicator { [self] in
                let conditions = try await fetchConditions(geoKey: geoKey, weatherKey: weatherKey)
                print(conditions)
            }
        } catch {
            let errMsg = ConsoleTextFragment(string: "\(error)", style: .error)
            terminal.output(ConsoleText(fragments: [errMsg]))
        }
    }

    private func fetchConditions(geoKey: String, weatherKey: String) async throws -> WeatherConditions {
        let ipClient = AmazonClient(apiProvider: .default)
        let ipAddress = try await ipClient.fetchIPAddress()

        let geoClient = GeolocatedIOClient(apiKey: geoKey, apiProvider: .default)
        let locationInfo = try await geoClient.geoLocation(ipAddress: ipAddress)

        let weatherClient = OpenWeatherMapClient(apiKey: weatherKey, apiProvider: .default)
        let owConditions = try await weatherClient.currentConditions(zip: locationInfo.zipCode)
        return WeatherConditions(from: owConditions)
    }
}
