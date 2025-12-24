import Foundation

private let DegreesSymbol = "°"

struct WeatherConditions {
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
}

struct GPS: CustomStringConvertible {
    let lat: Float
    let lon: Float

    var description: String {
        "\(lat)\(DegreesSymbol)\(lon)\(DegreesSymbol)"
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

    var description: String {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd `at` HH:mm zzz"
        df.timeZone = timezone

        return """
        \(country), \(name)
        Sunrise: \(df.string(from: sunrise))
        Sunset: \(df.string(from: sunset))
        \(gps)
        """
    }
}
