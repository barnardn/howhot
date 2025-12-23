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
            return payload.payload
        } catch {
            throw LookupError.network(error)
        }
    }
}

private class StringDecoder: NetworkDecoder {
    enum StringDecodingError: Error {
        case invalidUTF8
        case typeMismatch
        case badValue
    }

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        guard type == String.self else {
            throw StringDecodingError.typeMismatch
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw StringDecodingError.invalidUTF8
        }
        guard let retv = string as? T else {
            throw StringDecodingError.badValue
        }
        return retv
    }
}
