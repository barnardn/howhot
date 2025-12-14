import Foundation

public struct Coordinates: Decodable {
    public let lat: Float
    public let lon: Float
}

extension Coordinates: CustomStringConvertible {
    public var description: String {
        return "(\(lat), \(lon))"
    }
}

public struct Weather: Decodable {
    public let temp: Float
    public let feelsLike: Float
    public let tempMin: Float
    public let tempMax: Float
    public let pressure: Int
    public let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

extension Weather: CustomStringConvertible {
    public var description: String {
        return "Temp: \(temp)°, Feels Like: \(feelsLike)°, Min: \(tempMin)°, Max: \(tempMax)°, Pressure: \(pressure) hPa, Humidity: \(humidity)%"
    }
}

public struct System: Decodable {
    public let id: Int
    public let country: String
    public let sunrise: Int64
    public let sunset: Int64
}

extension System: CustomStringConvertible {
    public var description: String {
        return "Country: \(country), Sunrise: \(sunrise), Sunset: \(sunset)"
    }
}

public struct Wind: Decodable {
    public let speed: Float
    public let deg: Int
    public let gust: Float?
}

extension Wind: CustomStringConvertible {
    public var description: String {
        let gustInfo = gust.map { ", Gust: \($0) m/s" } ?? ""
        return "Speed: \(speed) m/s, Direction: \(deg)°\(gustInfo)"
    }
}

public struct Cloud: Decodable {
    public let all: Int
}

extension Cloud: CustomStringConvertible {
    public var description: String {
        return "Cloud Cover: \(all)%"
    }
}

public struct HourlyRate: Decodable {
    public let rate: Float

    enum CodingKeys: String, CodingKey {
        case rate = "1h"
    }
}

extension HourlyRate: CustomStringConvertible {
    public var description: String {
        return "\(rate) mm/h"
    }
}

public struct Conditions: Decodable {
    public let id: Int
    public let main: String
    public let conditionDescription: String
    public let icon: String

    enum CodingKeys: String, CodingKey {
        case id
        case main
        case conditionDescription = "description"
        case icon
    }
}

extension Conditions: CustomStringConvertible {
    public var description: String {
        return "\(main): \(conditionDescription)"
    }
}

public struct Container: Decodable {
    public let id: Int
    public let timezone: Int
    public let name: String
    public let visibility: Int
    public let coord: Coordinates
    public let sys: System
    public let main: Weather
    public let weather: [Conditions]
    public let wind: Wind?
    public let clouds: Cloud?
    public let rain: HourlyRate?
    public let snow: HourlyRate?
}

extension Container: CustomStringConvertible {
    public var description: String {
        var result = """
        Location: \(name) \(coord)
        \(main)
        Conditions: \(weather.map { $0.description }.joined(separator: ", "))
        """

        if let wind = wind {
            result += "\n\(wind)"
        }
        if let clouds = clouds {
            result += "\n\(clouds)"
        }
        if let rain = rain {
            result += "\nRain: \(rain)"
        }
        if let snow = snow {
            result += "\nSnow: \(snow)"
        }
        result += "\nVisibility: \(visibility) m"
        result += "\n\(sys)"

        return result
    }
}
