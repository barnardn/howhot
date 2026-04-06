import Foundation
#if os(Linux)
    import FoundationNetworking

    // macOS defines this in Network
    public protocol NetworkTransport: Sendable {
        func rawResponse(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
    }
#else
    import Network
#endif

extension URLSession: NetworkTransport {
    public func rawResponse(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, rsp) = try await data(for: request)
        guard let httpRsp = rsp as? HTTPURLResponse else {
            throw ApiError.badResponse(rsp)
        }
        guard HTTPStatusCode.successCodes.contains(httpRsp.statusCode) else {
            throw ApiError.requestFailed(httpRsp)
        }
        return (data, httpRsp)
    }
}
