import Foundation

public enum AppError: Error, CustomStringConvertible {
    case missingApiKey(String)
    case uncategorized(String)

    public var description: String {
        switch self {
        case let .missingApiKey(keyName):
            "Missing API key for \(keyName)"
        case let .uncategorized(message):
            "Uncategorized(\(message))"
        }
    }
}
