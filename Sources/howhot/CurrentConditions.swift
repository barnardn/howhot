import APINetworking
import ArgumentParser
import Common
import Configuration
import ConsoleKit
import Foundation
import OpenWeatherMap

struct CurrentConditionsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "conditions",
        abstract: "Get current the weather conditions from the current location."
    )

    @Argument(help: "The zip code of the current weather")
    var zip: String

    @Flag(help: "Metric units instead of imperial")
    var metric = false

    @Option(help: "Returns the values in the format string")
    var formatString: String? = nil

    mutating func run() async throws {
        let term = Terminal()
        let config = try await AppConfig.configReader()

        guard let apiKey = config.string(forKey: "openweathermap") else {
            throw AppError.missingApiKey("Openweathermap.org")
        }
        let client = OpenWeatherMapClient(apiKey: apiKey, apiProvider: .default)
        let owConditions = try await client.currentConditions(zip: zip, isMetric: metric)
        let conditions = WeatherConditions(from: owConditions)
        if let formatString {
            let r = try conditions.parse(format: formatString)
            let frag = ConsoleTextFragment(string: r, style: .init(color: .brightCyan))
            term.output(ConsoleText(fragments: [frag]))
        } else {
            print(conditions)
        }
    }
}
