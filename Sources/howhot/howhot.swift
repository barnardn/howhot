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

    @Flag(help: "Metric units instead of imperial")
    var metric = false

    @Flag(help: "Boring output mode, no colors nor loading indicator when showing or fetching weather.")
    var boringOutput = false
}

@main
struct howhot: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "howhot",
        abstract: "A command-line tool to check the weather.",
        discussion: "This tool uses the OpenWeatherMap API to retrieve weather information.",
        version: "1.0.1",
        subcommands: [GeocodeCommand.self, IPLookupCommand.self, CurrentConditionsCommand.self]
    )
    @OptionGroup var appOptions: AppOptions

    mutating func run() async throws {
        let config = try await AppConfig.configReader(configPath: appOptions.configFile)
        guard
            let geoKey = config.string(forKey: "geokey")
        else {
            throw AppError.missingApiKey("geokey")
        }
        guard
            let weatherKey = config.string(forKey: "openweathermap")
        else {
            throw AppError.missingApiKey("openweathermap")
        }

        let terminal = Terminal()
        do {
            if appOptions.boringOutput {
                let conditions = try await fetchConditions(geoKey: geoKey, weatherKey: weatherKey)
                terminal.output("\(conditions)")
            } else {
                let loadingBar = terminal.loadingBar(title: "Loading...")
                let conditions = try await loadingBar.withActivityIndicator { [self] in
                    try await fetchConditions(geoKey: geoKey, weatherKey: weatherKey)
                }
                let zoneMap = WeatherConditions.createZoneMap(configReader: config)
                let consolLines = conditions.fancyOutput(zoneMap: zoneMap)
                consolLines.forEach { line in
                    terminal.output(line, newLine: true)
                }
            }
        } catch {
            if let lookupError = error as? LookupError, case .network = lookupError {
                reportError(message: "Network error. Check connection and try again.", to: terminal)
            } else {
                reportError(message: "\(error)", to: terminal)
            }
        }
    }

    private func reportError(message: String, to terminal: Terminal) {
        if !appOptions.boringOutput {
            let errMsg = ConsoleTextFragment(string: "\(message)", style: .error)
            terminal.output(ConsoleText(fragments: [errMsg]))
        } else {
            terminal.output(message)
        }
    }

    private func fetchConditions(geoKey: String, weatherKey: String) async throws -> WeatherConditions {
        let ipClient = AmazonClient(apiProvider: .default)
        let ipAddress = try await ipClient.fetchIPAddress()

        let geoClient = GeolocatedIOClient(apiKey: geoKey, apiProvider: .default)
        let locationInfo = try await geoClient.geoLocation(ipAddress: ipAddress)

        let weatherClient = OpenWeatherMapClient(apiKey: weatherKey, apiProvider: .default)
        let owConditions = try await weatherClient.currentConditions(zip: locationInfo.zipCode, isMetric: appOptions.metric)
        return WeatherConditions(from: owConditions)
    }
}

extension Array {
    mutating func appendIf(_ maybeElement: Element?) {
        if let maybeElement {
            append(maybeElement)
        }
    }

    mutating func insertIf(_ maybeElement: Element?, at index: Index) {
        if let maybeElement {
            insert(maybeElement, at: index)
        }
    }

    mutating func pushIf(_ maybeElement: Element?) {
        insertIf(maybeElement, at: 0)
    }
}

extension WeatherConditions {
    static func createZoneMap(configReader: ConfigReader) -> WeatherConditions.ZoneMap {
        let zoneCfgReader = configReader.scoped(to: "zones")
        let keysAndValues = WeatherConditions.TempComfortZone.allCases.compactMap { zone in
            if let temp = zoneCfgReader.double(forKey: .init(zone.rawValue)) {
                return (zone, Float(temp))
            } else {
                return nil
            }
        }
        return keysAndValues.isEmpty ?
            WeatherConditions.TempComfortZone.defaultZoneMap :
            Dictionary(uniqueKeysWithValues: keysAndValues)
    }
}
