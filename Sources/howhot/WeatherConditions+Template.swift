import Foundation

private enum TemplateKey: String, CaseIterable {
    case temperature
    case feelsLike
    case localMin
    case localMax
    case humidity
    case wind
    case clouds
    case rain
    case snow
}

extension WeatherConditions {
    enum ParseError: Error {
        case invalidInput(String, [String])
        case placeholderValueMismatch(String, [String])
    }

    private var mapping: [TemplateKey: PartialKeyPath<WeatherConditions>] {
        [
            .temperature: \WeatherConditions.temperature,
            .feelsLike: \WeatherConditions.feelsLike,
            .localMin: \WeatherConditions.localMin,
            .localMax: \WeatherConditions.localMax,
            .humidity: \WeatherConditions.humidity,
            .wind: \WeatherConditions.surfaceWind,
            .clouds: \WeatherConditions.clouds,
            .rain: \WeatherConditions.rain,
            .snow: \WeatherConditions.snow,
        ]
    }

    private func templateKeys(_ str: String) throws -> [TemplateKey] {
        let pattern = /\{([^}]+)\}/
        let matches = str.matches(of: pattern)
        let keys = matches.map { String($0.1) }
        let allPossible = TemplateKey.allCases.map(\.rawValue)
        let unknown = keys.filter {
            !allPossible.contains($0)
        }
        if !unknown.isEmpty {
            throw ParseError.invalidInput(str, unknown)
        }
        return keys.compactMap(TemplateKey.init(rawValue:))
    }

    private func replaceKeysWithPlaceholders(_ str: String) -> String {
        return str.replacing(/\{\w+\}/, with: "%@")
    }

    private func description(for key: TemplateKey) throws -> String? {
        guard
            let keyPath = mapping[key],
            let value = self[keyPath: keyPath] as? CustomStringConvertible
        else {
            return nil
        }
        return value.description
    }

    func parse(format: String) throws -> String {
        let keys = try templateKeys(format)
        let replacementValues = try keys.compactMap(description(for:))
        let placeholder = replaceKeysWithPlaceholders(format)
        return String(format: placeholder, arguments: replacementValues)
    }
}
