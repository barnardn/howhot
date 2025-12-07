import APINetworking
import Foundation

public enum GeoLocationError: Error {
    case invalidURL
    case badResponse(Data?)
    case network(Error)
    case badEncoding(DecodingError)
}

final public class GeolocatedIOClient {
    private let successCodes = Set([200, 201, 202, 203, 204, 205])
    private let host = "us-west-1.geolocated.io"
    private let apiKey: String
    private let apiProvider: APIProvider

    public init(apiKey: String, apiProvider: APIProvider) {
        self.apiKey = apiKey
        self.apiProvider = apiProvider
    }

    public func geoLocation(ipAddress: String) async throws -> LocationInfo {
        let path = "ip/\(ipAddress)?api-key=\(apiKey)"
        let urlString = "https://\(host)/\(path)"

        guard let url = URL(string: urlString) else {
            throw ApiError.badURL(urlString)
        }
        do {
            let (location, _): (StandardLookupResponse, _) = try await apiProvider.apiResponse(request: URLRequest(url: url))
            return location.toLocationInfo()

        } catch let error as DecodingError {
            throw GeoLocationError.badEncoding(error)
        } catch let error as GeoLocationError {
            throw error
        } catch {
            throw GeoLocationError.network(error)
        }
    }
}
