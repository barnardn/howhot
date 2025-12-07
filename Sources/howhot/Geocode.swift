import ArgumentParser
import Foundation
import GeoLookup

struct GeocodeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "geocode",
        abstract: "Determine location via IP address lookup"
    )

    @Argument(help: "The ip address to geocode")
    var address: String

    mutating func run() async throws {
        let client = GeolocatedIOClient(apiKey: "", apiProvider: .default)
        let locationInfo = try await client.geoLocation(ipAddress: address)
        print(locationInfo.description)
    }
}
