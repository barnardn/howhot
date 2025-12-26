import APINetworking
import Common
import Foundation

final public class OpenWeatherMapClient: Sendable {
    private let host = "api.openweathermap.org"
    private let conditionsPath = "data/2.5/weather?appid=%@&zip=%@&units=%@"
    private let apiKey: String
    private let apiProvider: APIProvider

    public init(apiKey: String, apiProvider: APIProvider) {
        self.apiKey = apiKey
        self.apiProvider = apiProvider
    }

    public func currentConditions(zip: String, isMetric: Bool = false) async throws -> Container {
        let units = isMetric ? "metric" : "imperial"
        let path = String(format: conditionsPath, apiKey, zip, units)
        let link = "https://\(host)/\(path)"

        guard let url = URL(string: link) else {
            throw AppError.uncategorized("bad url \(link)")
        }

        do {
            let response = try await apiProvider.apiResponse(Container.self, request: .init(url: url))
            return response.payload
        } catch {
            throw AppError.uncategorized(error.localizedDescription)
        }
    }
}
