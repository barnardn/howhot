import APINetworking
import ArgumentParser
import Common
import Configuration
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

    mutating func run() async throws {
        let config = try await AppConfig.configReader()

        guard let apiKey = config.string(forKey: "openweathermap") else {
            throw AppError.missingApiKey("Openweathermap.org")
        }
        let client = OpenWeatherMapClient(apiKey: apiKey, apiProvider: .default)
        let conditions = try await client.currentConditions(zip: zip, isMetric: metric)
        print(conditions)
    }
}
