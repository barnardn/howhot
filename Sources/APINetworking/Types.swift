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
