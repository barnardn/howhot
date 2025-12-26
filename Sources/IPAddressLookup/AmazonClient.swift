import APINetworking
import Foundation
import Network

public enum LookupError: Error {
    case badIPAddress(Data?)
    case network(Error)
}

final public class AmazonClient {
    private let url = URL(string: "https://checkip.amazonaws.com")!
    private let apiProvider: APIProvider

    public init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }

    public func fetchIPAddress() async throws -> String {
        do {
            let payload = try await apiProvider.apiResponse(String.self, url: url, decoder: StringDecoder())
            return payload.payload.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw LookupError.network(error)
        }
    }
}
