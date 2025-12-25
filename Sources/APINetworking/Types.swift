import Foundation

/// Error thrown by APINetworking functions
public enum ApiError: Error {
    case badResponse(URLResponse)
    case requestFailed(HTTPURLResponse)
    case decoding(DecodingError)
    case badURL(String)
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
        case let .decoding(deocodeError):
            "Decoding error: \(deocodeError)"
        case let .badURL(link):
            "Bad URL representation: \(link)"
        }
    }
}
