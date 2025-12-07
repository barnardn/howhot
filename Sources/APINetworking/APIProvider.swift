import Foundation
import Network

public class APIProvider {
    private let transport: NetworkTransport

    public init(transport: NetworkTransport = URLSession.shared) {
        self.transport = transport
    }

    public func apiResponse<ReturnType: Decodable>(request: URLRequest, decoder: NetworkDecoder = JSONDecoder()) async throws -> (ReturnType, HTTPURLResponse) {
        let (data, rsp) = try await transport.rawResponse(for: request)
        let value = try decoder.decode(ReturnType.self, from: data)
        return (value, rsp)
    }

    public func apiResponse(request: URLRequest) async throws -> (EmptyResponse, HTTPURLResponse) {
        let (_, rsp) = try await transport.rawResponse(for: request)
        return (EmptyResponse(), rsp)
    }
}

public extension APIProvider {
    static var `default`: APIProvider {
        APIProvider()
    }
}
