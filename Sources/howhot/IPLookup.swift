import ArgumentParser
import Foundation

struct IPLookupCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "iplookup",
        abstract: "Get the configured public IP address.",
    )

    mutating func run() throws {
        print("Fetching public IP address...")
    }
}
