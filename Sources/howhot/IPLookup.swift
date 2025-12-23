import APINetworking
import ArgumentParser
import Foundation
import IPAddressLookup

struct IPLookupCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "iplookup",
        abstract: "Get the configured public IP address."
    )

    mutating func run() async throws {
        let client = AmazonClient(apiProvider: .default)
        let ipAddress = try await client.fetchIPAddress()
        print("\(ipAddress)")
    }
}
