import Foundation

public enum AppError: Error, CustomStringConvertible {
    case missingApiKey(String)

    public var description: String {
        switch self {
        case let .missingApiKey(keyName):
            "Missing API key for \(keyName)"
        }
    }
}
