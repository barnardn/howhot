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

    @Flag(help: "Boring output mode, no colors nor loading indicator")
    var boringOutput = false

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
        do {
            if boringOutput {
                let conditions = try await fetchConditions(geoKey: geoKey, weatherKey: weatherKey)
                terminal.output("\(conditions)")
            } else {
                try await fancyOutput(terminal: terminal, geoKey: geoKey, weatherKey: weatherKey)
            }
        } catch {
            if !boringOutput {
                let errMsg = ConsoleTextFragment(string: "\(error)", style: .error)
                terminal.output(ConsoleText(fragments: [errMsg]))
            } else {
                terminal.output("\(error)")
            }
        }
    }

    private func fancyOutput(terminal: Terminal, geoKey: String, weatherKey: String) async throws {
        let terminal = Terminal()
        let loadingBar = terminal.loadingBar(title: "Loading...")
        let conditions = try await loadingBar.withActivityIndicator { [self] in
            try await fetchConditions(geoKey: geoKey, weatherKey: weatherKey)
        }
        let headerFrag = ConsoleTextFragment(string: conditions.header, style: .init(color: .brightWhite, isBold: true))
        let locationLines = conditions.locationLines()
        let tempLines = conditions.temperatureLines()
        let humidLine = conditions.textLine(for: "Humidity", value: "\(conditions.humidity)")
        var allLines = [
            ConsoleText(fragments: [headerFrag]),
        ]
        allLines.append(contentsOf: locationLines)
        allLines.append(contentsOf: tempLines)
        allLines.append(humidLine)
        let windLine = conditions.surfaceWind.flatMap { ws -> ConsoleText in
            var fragments = [
                ConsoleTextFragment(string: "Wind Speed: "),
                ConsoleTextFragment(string: "\(ws.winds)", style: .init(isBold: true)),
                ConsoleTextFragment(string: " at "),
                ConsoleTextFragment(string: "\(ws.degrees)", style: .init(isBold: true)),
            ]
            if let gust = ws.gusts {
                fragments.append(
                    ConsoleTextFragment(string: " with gusts at ")
                )
                fragments.append(
                    ConsoleTextFragment(string: "\(gust)", style: .init(isBold: true))
                )
            }
            return ConsoleText(fragments: fragments)
        }
        allLines.appendIf(windLine)
        if let clouds = conditions.clouds {
            allLines.append(
                conditions.textLine(for: "Cloud Cover", value: "\(clouds)")
            )
        }
        if let rain = conditions.rain {
            allLines.append(
                conditions.textLine(for: "Rain", value: "\(rain)")
            )
        }
        if let snow = conditions.snow {
            allLines.append(
                conditions.textLine(for: "Snow", value: "\(snow)")
            )
        }
        for line in allLines {
            terminal.output(line, newLine: true)
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

extension WeatherConditions {
    enum TempComfortZone {
        case bitter
        case cold
        case chilly
        case pleasant
        case warm
        case hot
        case sweltering

        static func zone(for temp: Temperature) -> Self {
            switch temp.reading {
            case ..<20:
                .bitter
            case 20..<32:
                .cold
            case 32..<50:
                .chilly
            case 50..<75:
                .pleasant
            case 75..<81:
                .warm
            case 81..<90:
                .hot
            default:
                .sweltering
            }
        }

        var outputStyle: ConsoleStyle {
            switch self {
            case .bitter:
                ConsoleStyle(color: .brightBlue, isBold: true)
            case .cold:
                ConsoleStyle(color: .blue)
            case .chilly:
                ConsoleStyle(color: .cyan)
            case .pleasant:
                ConsoleStyle(color: .brightGreen)
            case .warm:
                ConsoleStyle(color: .brightYellow)
            case .hot:
                ConsoleStyle(color: .red)
            default:
                ConsoleStyle(color: .brightRed)
            }
        }
    }

    func temperatureLines() -> [ConsoleText] {
        let labels = ["Temperature: ", "Feels Like: ", "Coldest Reported: ", "Warmest Reported: "]
        let labelFragments = labels.map(ConsoleTextFragment.init)
        let readings = [temperature, feelsLike, localMin, localMax]
        let readingFragments = readings.map { temp in
            let zone = TempComfortZone.zone(for: temp)
            let rdgStr = "\(temp)"
            return ConsoleTextFragment(string: rdgStr, style: zone.outputStyle)
        }
        return zip(labelFragments, readingFragments).map { label, reading in
            ConsoleText(fragments: [label, reading])
        }
    }

    func locationLines() -> [ConsoleText] {
        [
            ConsoleText(stringLiteral: "\(location.country), \(location.name)"),
            textLine(for: "Sunrise", value: location.formattedSunrise),
            textLine(for: "Sunset", value: location.formattedSunset),
            textLine(for: "Coordinates", value: "\(location.gps)"),
        ]
    }

    func textLine(for label: String, value: String) -> ConsoleText {
        let labelFrag = ConsoleTextFragment(string: "\(label): ")
        let valueFrag = ConsoleTextFragment(string: value, style: .init(isBold: true))
        return ConsoleText(fragments: [labelFrag, valueFrag])
    }
}

extension Array {
    mutating func appendIf(_ maybeElement: Element?) {
        if let maybeElement {
            append(maybeElement)
        }
    }
}
