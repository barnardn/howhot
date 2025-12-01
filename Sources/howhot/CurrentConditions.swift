import ArgumentParser
import Foundation

struct CurrentConditionsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "conditions",
        abstract: "Get current the weather conditions from the current location.",
    )

    mutating func run() throws {
        print("Getting current weather conditions...")
    }
}
