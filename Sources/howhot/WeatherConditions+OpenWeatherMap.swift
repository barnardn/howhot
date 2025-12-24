import Foundation
import OpenWeatherMap

extension WeatherConditions {
    init(from owm: Container, isMetric: Bool = false) {
        let gps = GPS(lat: owm.coord.lat, lon: owm.coord.lon)
        let details = LocationDetails(
            country: owm.sys.country,
            name: owm.name,
            sunrise: Date(timeIntervalSince1970: TimeInterval(owm.sys.sunrise)),
            sunset: Date(timeIntervalSince1970: TimeInterval(owm.sys.sunset)),
            gps: gps,
            tzOffset: owm.timezone
        )
        self.location = details
        self.summary = owm.weather.map(\.conditionDescription).joined(separator: "\n")
        self.temperature = Temperature.measured(value: owm.main.temp, isMetric: isMetric)
        self.feelsLike = Temperature.measured(value: owm.main.feelsLike, isMetric: isMetric)
        self.localMin = Temperature.measured(value: owm.main.tempMin, isMetric: isMetric)
        self.localMax = Temperature.measured(value: owm.main.tempMax, isMetric: isMetric)
        self.humidity = PercentReading(reading: Float(owm.main.humidity))
        self.surfaceWind = owm.wind.flatMap { w in
            SurfaceWind(windSpeed: w.speed, gustSpeed: w.gust, degrees: w.deg, isMetric: isMetric)
        }
        self.clouds = owm.clouds.flatMap {
            PercentReading(reading: Float($0.all))
        }
        self.rain = owm.rain.flatMap {
            RatePerHour.measured(reading: $0.rate, isMetric: isMetric)
        }
        self.snow = owm.snow.flatMap {
            RatePerHour.measured(reading: $0.rate, isMetric: isMetric)
        }
    }
}
