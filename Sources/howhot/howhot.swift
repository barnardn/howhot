import ArgumentParser
import Configuration
import Foundation
import SystemPackage

struct AppOptions: ParsableArguments {
    static let defaultConfigPath = "~/.config/howhot.yaml"
    @Option(name: .shortAndLong, help: "Alternative configuration file (default: \(defaultConfigPath))")
    var configFile: String?
}

@main
struct howhot: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "howhot",
        abstract: "A command-line tool to check the weather.",
        discussion: "This tool uses the OpenWeatherMap API to retrieve weather information.",
        version: "1.0.0",
        subcommands: [GeocodeCommand.self, IPLookupCommand.self, CurrentConditionsCommand.self]
    )
    @OptionGroup var appOptions: AppOptions

    mutating func run() async throws { }
}
