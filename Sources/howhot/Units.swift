import Foundation

enum Speed: CustomStringConvertible {
    case mph(Float)
    case kph(Float)

    var magnitude: Float {
        return switch self {
        case let .kph(mag),
             let .mph(mag):
            mag
        }
    }

    var description: String {
        let units = switch self {
        case .mph:
            "mph"
        case .kph:
            "kph"
        }
        return String(format: "%0.1f%@", magnitude, units)
    }
}

struct PercentReading: CustomStringConvertible {
    let reading: Float

    var description: String {
        String(format: "%0.1f%%", reading)
    }
}

enum RatePerHour: CustomStringConvertible {
    case mm(Float)
    case inches(Float)

    var reading: Float {
        return switch self {
        case let .mm(reading),
             let .inches(reading):
            reading
        }
    }

    var description: String {
        let units = switch self {
        case .mm:
            "mm/hour"
        case .inches:
            "inches/hour"
        }
        return String(format: "%0.1f %@", reading, units)
    }

    static func measured(reading: Float, isMetric: Bool = false) -> Self {
        isMetric ? .mm(reading) : .inches(reading)
    }
}

enum Temperature: CustomStringConvertible {
    case celsius(Float)
    case fahrenheit(Float)

    var reading: Float {
        return switch self {
        case let .fahrenheit(reading),
             let .celsius(reading):
            reading
        }
    }

    func toCelsius() -> Self {
        guard case .fahrenheit = self else { return self }
        return .celsius((reading - 32.0) * 5 / 9)
    }

    func toFahrenheit() -> Self {
        guard case .celsius = self else { return self }
        return .fahrenheit(reading * 1.8 + 32.0)
    }

    var description: String {
        let units = switch self {
        case .celsius:
            "℃"
        case .fahrenheit:
            "℉"
        }
        return String(format: "%0.1f%@", reading, units)
    }

    static func measured(value: Float, isMetric: Bool) -> Temperature {
        isMetric ? .celsius(value) : .fahrenheit(value)
    }
}
