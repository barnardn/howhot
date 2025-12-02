import Foundation

public enum LookupError: Error {
    case badIPAddress(Data?)
    case network(Error)
}

final public class AmazonClient {
    private let url = URL(string: "https://checkip.amazonaws.com")!

    public init() { }

    public func fetchIPAddress() async throws -> String {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let ipAddress = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return ipAddress
            }
            throw LookupError.badIPAddress(data)
        } catch {
            throw LookupError.network(error)
        }
    }
}
