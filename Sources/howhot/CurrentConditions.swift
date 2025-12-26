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
        commandName: "conditions",
        abstract: "Get current the weather conditions from the current location."
    )

    @Argument(help: "The zip code of the current weather")
    var zip: String

    @Option(help: "Returns the values in the format string (implies boring output mode")
    var formatString: String? = nil

    mutating func run() async throws {
        let config = try await AppConfig.configReader(configPath: appOptions.configFile)
        guard let apiKey = config.string(forKey: "openweathermap") else {
            throw AppError.missingApiKey("openweathermap")
        }
        let terminal = Terminal()
        let client = OpenWeatherMapClient(apiKey: apiKey, apiProvider: .default)
        let conditions: WeatherConditions
        if appOptions.boringOutput || formatString != nil {
            let owConditions = try await client.currentConditions(zip: zip, isMetric: appOptions.metric)
            conditions = WeatherConditions(from: owConditions, isMetric: appOptions.metric)
            if let formatString {
                let formatted = try conditions.parse(format: formatString)
                print(formatted)
            } else {
                print(conditions)
            }
        } else {
            let loadingBar = terminal.loadingBar(title: "Loading...")
            conditions = try await loadingBar.withActivityIndicator { [zip, isMetric = appOptions.metric] in
                let owConditions = try await client.currentConditions(zip: zip, isMetric: isMetric)
                return WeatherConditions(from: owConditions, isMetric: isMetric)
            }
            let consoleLines = conditions.fancyOutput()
            consoleLines.forEach { line in
                terminal.output(line, newLine: true)
            }
        }
    }
}
