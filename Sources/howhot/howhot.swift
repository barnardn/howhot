import ArgumentParser
import Configuration
import Foundation
import SystemPackage

@main
struct howhot: AsyncParsableCommand {
    enum Constants {
        static let defaultConfigPath = "~/.configX/howhot.yaml"
    }

    static let configuration = CommandConfiguration(
        commandName: "howhot",
        abstract: "A command-line tool to check the weather.",
        discussion: "This tool uses the OpenWeatherMap API to retrieve weather information.",
        version: "1.0.0",
        subcommands: [GeocodeCommand.self, IPLookupCommand.self, CurrentConditionsCommand.self]
    )

    @Option(name: .shortAndLong, help: "Alternative configuration file (default: \(Constants.defaultConfigPath))")
    var altConfig: String?

    mutating func run() async throws {
        let environmentProvider = EnvironmentVariablesProvider().prefixKeys(with: "howhot")

        let configURL: URL
        if let altConfig {
            configURL = URL(fileURLWithPath: altConfig)
        } else {
            configURL = URL(fileURLWithPath: Constants.defaultConfigPath)
        }
        let path = FilePath(stringLiteral: configURL.path())
        let config = try ConfigReader(providers: [
            // prefer values from environment..
            environmentProvider,
            // fall back to configuration file
            await FileProvider<YAMLSnapshot>(filePath: path, allowMissing: true),
        ])
        guard let openWeatherMapApiKey = config.string(forKey: "openweathermap") else {
            throw AppError.missingApiKey("Openweathermap.org")
        }
        guard let geocodeApiKey = config.string(forKey: "geokey") else {
            throw AppError.missingApiKey("Geocoded.io")
        }
    }
}

enum AppError: Error, CustomStringConvertible {
    case missingApiKey(String)

    var description: String {
        switch self {
        case let .missingApiKey(keyName):
            "Missing API key for \(keyName)"
        }
    }
}
