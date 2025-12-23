import Foundation
import Network

public struct APIResponse<RT: Decodable> {
    public let payload: RT
    public let response: HTTPURLResponse
}

public class APIProvider {
    private let transport: NetworkTransport

    public init(transport: NetworkTransport = URLSession.shared) {
        self.transport = transport
    }

    public func apiResponse<RT: Decodable>(_ payloadType: RT.Type, url: URL, decoder: NetworkDecoder = JSONDecoder()) async throws -> APIResponse<RT> {
        try await apiResponse(payloadType, request: URLRequest(url: url), decoder: decoder)
    }

    public func apiResponse<RT: Decodable>(_ payloadType: RT.Type, request: URLRequest, decoder: NetworkDecoder = JSONDecoder()) async throws -> APIResponse<RT> {
        let (data, rsp) = try await transport.rawResponse(for: request)
        let payload = try decoder.decode(RT.self, from: data)
        return APIResponse(payload: payload, response: rsp)
    }

    public func apiResponse(url: URL, decoder: NetworkDecoder = JSONDecoder()) async throws -> APIResponse<EmptyResponse> {
        try await apiResponse(request: URLRequest(url: url), decoder: decoder)
    }

    public func apiResponse(request: URLRequest, decoder: NetworkDecoder = JSONDecoder()) async throws -> APIResponse<EmptyResponse> {
        let (_, rsp) = try await transport.rawResponse(for: request)
        return APIResponse(payload: EmptyResponse(), response: rsp)
    }
}

public extension APIResponse {
    var isEmpty: Bool {
        payload is EmptyResponse
    }
}

public extension APIProvider {
    static var `default`: APIProvider {
        APIProvider()
    }
}
