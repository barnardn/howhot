// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct howhot: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "howhot",
        abstract: "A command-line tool to check the weather.",
        discussion: "This tool uses the OpenWeatherMap API to retrieve weather information.",
        version: "1.0.0",
        subcommands: [GeocodeCommand.self, IPLookupCommand.self, CurrentConditionsCommand.self]
    )

    mutating func run() throws {
        let apiKey = ProcessInfo.processInfo.environment["OPENWEATHERMAP_API"] ?? "crap"
        print("APIKey: \(apiKey)")
    }
}
