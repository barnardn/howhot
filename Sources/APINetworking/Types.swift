import Foundation
import Network

/// Error thrown by APINetworking functions
public enum ApiError: Error {
    case badResponse(URLResponse)
    case requestFailed(HTTPURLResponse)
    case decoding(DecodingError)
    case badURL(String)
}

public enum HTTPStatusCode {
    public static let successCodes: Set<Int> = [200, 201, 202, 203, 204, 205]
}

/// Return type for Api responses that return an empty body
public struct EmptyResponse: Equatable, Decodable {
    public init() { }
}

extension ApiError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .badResponse(urlRsp):
            if let url = urlRsp.url {
                "Bad Response: \(url)"
            } else {
                "Bad Response"
            }
        case let .requestFailed(httpRsp):
            if let url = httpRsp.url {
                "Request Failed (status: \(httpRsp.statusCode)): \(url)"
            } else {
                "Request Failed (status: \(httpRsp.statusCode))"
            }
        case let .decoding(decodeError):
            "Decoding error: \(decodeError)"
        case let .badURL(link):
            "Bad URL representation: \(link)"
        }
    }
}

public class StringDecoder: NetworkDecoder {
    public enum StringDecodingError: Error {
        case invalidUTF8
        case typeMismatch
        case badValue
    }

    public init() { }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
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
