import APINetworking
import ArgumentParser
import Common
import Configuration
import ConsoleKit
import Foundation
import OpenWeatherMap

struct CurrentConditionsCommand: AsyncParsableCommand {
    @OptionGroup var appOptions: AppOptions

    static let configuration = CommandConfiguration(
        commandName: "weather", abstract: "Get current the weather conditions from the specified location."
    )

    var boringOutput: Bool {
        appOptions.boringOutput || formatString != nil || jsonOutput
    }

    var coordinates: Common.Coordinates? {
        guard
            let parts = gps?.components(separatedBy: ","),
            parts.count == 2,
            let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
            let lon = Double(parts[1].trimmingCharacters(in: .whitespaces))
        else {
            return nil
        }
        return .init(latitude: lat, longitude: lon)
    }

    @Option(name: .long, help: "The locations zip code") var zip: String?
    @Option(name: .long, help: "The locations gps coordinates") var gps: String?

    @Option(help: "Returns the values in the format string (implies boring output mode)") var formatString: String? = nil
    @Flag(help: "Returns the weather conditions as a JSON object (implies boring output mode)") var jsonOutput = false

    mutating func validate() throws {
        if zip == nil && gps == nil {
            throw ValidationError("You must specifiy a zip code or gps coordinates")
        }
        if zip != nil {
            return
        }
        guard let coordinates else {
            throw ValidationError("You must specifiy valid gps coordinates: \"lat,lon\"")
        }
        guard coordinates.latitude <= 90 && coordinates.latitude >= -90 else {
            throw ValidationError("Latitude must be in range [-90, 90")
        }
        guard coordinates.longitude <= 180 && coordinates.longitude >= -180 else {
            throw ValidationError("Longitude must be in rnage [-180, 180]")
        }
    }

    mutating func run() async throws {
        let config = try await AppConfig.configReader(configPath: appOptions.configFile)
        guard let apiKey = config.string(forKey: "openweathermap") else {
            throw AppError.missingApiKey("openweathermap")
        }
        let terminal = Terminal()
        let client = OpenWeatherMapClient(apiKey: apiKey, apiProvider: .default)
        let conditions: WeatherConditions
        if boringOutput {
            let owConditions = try await fetchConditions(client, metric: appOptions.metric)
            conditions = WeatherConditions(from: owConditions, isMetric: appOptions.metric)
            if let formatString {
                let formatted = try conditions.parse(format: formatString)
                print(formatted)
            } else if jsonOutput {
                switch conditions.asJson() {
                case let .success(.some(str)):
                    print(str)
                case .success(.none):
                    print("JSON encoding returned empty string")
                case let .failure(error):
                    print(error.localizedDescription)
                }
            } else {
                print(conditions)
            }
        } else {
            let loadingBar = terminal.loadingBar(title: "Loading...")
            conditions = try await loadingBar.withActivityIndicator { [self, isMetric = appOptions.metric] in
                let owConditions = try await fetchConditions(client, metric: isMetric)
                return WeatherConditions(from: owConditions, isMetric: isMetric)
            }
            let zoneMap = WeatherConditions.createZoneMap(configReader: config)
            let consoleLines = conditions.fancyOutput(zoneMap: zoneMap)
            consoleLines.forEach { line in terminal.output(line, newLine: true) }
        }
    }

    private func fetchConditions(_ client: OpenWeatherMapClient, metric: Bool) async throws -> Container {
        if let zip {
            return try await client.currentConditions(zip: zip, isMetric: metric)
        }
        guard let coordinates else {
            throw ValidationError("Latitude and longitude are required")
        }
        return try await client.currentConditions(
            location: coordinates,
            isMetric: metric
        )
    }
}

private extension WeatherConditions {
    func asJson() -> Result<String?, Error> {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return .success(String(data: jsonData, encoding: .utf8))
        } catch {
            return .failure(error)
        }
    }
}
