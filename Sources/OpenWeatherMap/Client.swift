import APINetworking
import Common
import Foundation

final public class OpenWeatherMapClient {
    private let successCodes = Set([200, 201, 202, 203, 204, 205])
    private let host = "api.openweathermap.org"
    private let conditionsPath = "data/2.5/weather?appid=%@&zip=%@&units=%@"
    private let apiKey: String
    private let apiProvider: APIProvider

    public init(apiKey: String, apiProvider: APIProvider) {
        self.apiKey = apiKey
        self.apiProvider = apiProvider
    }

    public func currentConditions(zip: String) async throws -> Container {
        let path = String.init(format: conditionsPath, apiKey, zip, "imperial")
        let link = "https://\(host)/\(path)"

        guard let url = URL(string: link) else {
            throw AppError.uncategorized("bad url \(link)")
        }

        do {
            let (conditions, _): (Container, _) = try await apiProvider.apiResponse(request: .init(url: url))
            return conditions
        } catch {
            throw AppError.uncategorized(error.localizedDescription)
        }
    }
}
