import Foundation

private let DegreesSymbol = "°"

struct WeatherConditions: CustomStringConvertible {
    let location: LocationDetails
    let summary: String // conditionDescription
    let temperature: Temperature
    let feelsLike: Temperature
    let localMin: Temperature
    let localMax: Temperature
    let humidity: PercentReading
    let surfaceWind: SurfaceWind?
    let clouds: PercentReading?
    let rain: RatePerHour?
    let snow: RatePerHour?

    var header: String {
        """
        Current Weather Conditions
        ------- ------- ----------
        """
    }

    var description: String {
        let nonOptional = """
        \(header)
        \(location)
        \(summary)
        Temperature: \(temperature)
        Feels Like: \(feelsLike)
        Highest Reported: \(localMax)
        Lowest Reported: \(localMin)
        Humidity: \(humidity)
        """
        let maybeValues = [
            surfaceWind.flatMap { "\($0)" },
            clouds.flatMap { "Cloud Cover: \($0)" },
            rain.flatMap { "Rain: \($0)" },
            snow.flatMap { "Snow: \($0) " },
        ]
        .compactMap { $0 }
        return "\(nonOptional)\n\(maybeValues.joined(separator: "\n"))"
    }
}

struct GPS: CustomStringConvertible {
    let lat: Float
    let lon: Float

    var description: String {
        "\(lat)\(DegreesSymbol), \(lon)\(DegreesSymbol)"
    }
}

struct SurfaceWind: CustomStringConvertible {
    let winds: Speed
    let gusts: Speed?
    let degrees: Int

    init(windSpeed: Float, gustSpeed: Float?, degrees: Int, isMetric: Bool = false) {
        self.degrees = degrees
        self.winds = isMetric ? .kph(windSpeed) : .mph(windSpeed)
        if let gustSpeed {
            self.gusts = isMetric ? .kph(gustSpeed) : .mph(gustSpeed)
        } else {
            self.gusts = nil
        }
    }

    var description: String {
        let ws = "Wind Speed: \(winds) at \(degrees)\(DegreesSymbol)"
        if let gusts {
            return "\(ws) with Gusts at \(gusts)"
        }
        return ws
    }
}

struct LocationDetails: CustomStringConvertible {
    let country: String
    let name: String
    let sunrise: Date
    let sunset: Date
    let gps: GPS
    let timezone: TimeZone

    init(country: String, name: String, sunrise: Date, sunset: Date, gps: GPS, tzOffset: Int) {
        self.country = country
        self.name = name
        self.sunset = sunset
        self.sunrise = sunrise
        self.gps = gps
        self.timezone = TimeZone(secondsFromGMT: tzOffset) ?? .gmt
    }

    private func localDateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd 'at' h:mm a zzz"
        df.timeZone = timezone
        return df
    }

    var formattedSunrise: String {
        let df = localDateFormatter()
        return df.string(from: sunrise)
    }

    var formattedSunset: String {
        let df = localDateFormatter()
        return df.string(from: sunset)
    }

    var description: String {
        let df = localDateFormatter()
        return """
        \(country), \(name)
        Sunrise: \(df.string(from: sunrise))
        Sunset: \(df.string(from: sunset))
        Coordinates: \(gps)
        """
    }
}
