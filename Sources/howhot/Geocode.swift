import ArgumentParser
import Foundation

struct GeocodeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "geocode",
        abstract: "Determine location via IP address lookup"
    )

    @Argument(help: "The ip address to geocode")
    var address: String

    mutating func run() throws {
        print("Geocoding \(address)...")
    }
}
