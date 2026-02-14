import ConsoleKit
import Foundation

extension WeatherConditions {
    public typealias ZoneMap = [TempComfortZone: Float]

    public enum TempComfortZone: String, CaseIterable {
        case bitter
        case cold
        case chilly
        case pleasant
        case warm
        case hot
        case sweltering

        static func zone(for temp: Temperature, zoneMap: ZoneMap = defaultZoneMap) -> Self {
            let tempInF = temp.toFahrenheit().reading.rounded()
            let returnZone = TempComfortZone.allCases.first { zone in
                let maxTemp = zoneMap[zone] ?? -1_000
                return maxTemp > tempInF
            }
            return returnZone ?? .sweltering
        }

        var outputStyle: ConsoleStyle {
            switch self {
            case .bitter:
                ConsoleStyle(color: .brightBlue, isBold: true)
            case .cold:
                ConsoleStyle(color: .blue)
            case .chilly:
                ConsoleStyle(color: .brightCyan)
            case .pleasant:
                ConsoleStyle(color: .brightGreen)
            case .warm:
                ConsoleStyle(color: .brightYellow)
            case .hot:
                ConsoleStyle(color: .red)
            default:
                ConsoleStyle(color: .brightRed, isBold: true)
            }
        }
    }

    func fancyOutput(zoneMap: ZoneMap) -> [ConsoleText] {
        let headerFrag = ConsoleTextFragment(string: header, style: .init(color: .brightWhite, isBold: true))
        let locationLines = locationLines()
        let tempLines = temperatureLines(zoneMap: zoneMap)
        let humidLine = textLine(for: "Humidity", value: "\(humidity)")
        var allLines = [
            ConsoleText(fragments: [headerFrag]),
        ]
        allLines.append(contentsOf: locationLines)
        allLines.append(contentsOf: tempLines)
        allLines.append(humidLine)
        allLines.append(
            ConsoleText(fragments: [ConsoleTextFragment(string: summary, style: .init(isBold: true))])
        )
        let windLine = surfaceWind.flatMap { ws -> ConsoleText in
            var fragments = [
                ConsoleTextFragment(string: "Wind Speed: "),
                ConsoleTextFragment(string: "\(ws.winds)", style: .init(isBold: true)),
                ConsoleTextFragment(string: " at "),
                ConsoleTextFragment(string: "\(ws.degrees)°", style: .init(isBold: true)),
            ]
            if let gust = ws.gusts {
                fragments.append(
                    ConsoleTextFragment(string: " with gusts at ")
                )
                fragments.append(
                    ConsoleTextFragment(string: "\(gust)", style: .init(isBold: true))
                )
            }
            return ConsoleText(fragments: fragments)
        }
        allLines.appendIf(windLine)
        let cloudLine = clouds.flatMap { clouds in
            textLine(for: "Cloud Cover", value: "\(clouds)")
        }
        allLines.appendIf(cloudLine)

        let rainLine = rain.flatMap { rain in
            textLine(for: "Rain", value: "\(rain)")
        }
        allLines.appendIf(rainLine)

        let snowLine = snow.flatMap { snow in
            textLine(for: "Snow", value: "\(snow)")
        }
        allLines.appendIf(snowLine)
        return allLines
    }

    func temperatureLines(zoneMap: ZoneMap) -> [ConsoleText] {
        let labels = ["Temperature: ", "Feels Like: ", "Coldest Reported: ", "Warmest Reported: "]
        let labelFragments = labels.map(ConsoleTextFragment.init)
        let readings = [temperature, feelsLike, localMin, localMax]
        let readingFragments = readings.map { temp in
            let zone = TempComfortZone.zone(for: temp, zoneMap: zoneMap)
            let rdgStr = "\(temp)"
            return ConsoleTextFragment(string: rdgStr, style: zone.outputStyle)
        }
        return zip(labelFragments, readingFragments).map { label, reading in
            ConsoleText(fragments: [label, reading])
        }
    }

    func locationLines() -> [ConsoleText] {
        [
            ConsoleText(stringLiteral: "\(location.country), \(location.name)"),
            textLine(for: "Sunrise", value: location.formattedSunrise),
            textLine(for: "Sunset", value: location.formattedSunset),
            textLine(for: "Coordinates", value: "\(location.gps)"),
        ]
    }

    func textLine(for label: String, value: String) -> ConsoleText {
        let labelFrag = ConsoleTextFragment(string: "\(label): ")
        let valueFrag = ConsoleTextFragment(string: value, style: .init(isBold: true))
        return ConsoleText(fragments: [labelFrag, valueFrag])
    }
}

extension WeatherConditions.TempComfortZone {
    static var defaultZoneMap: WeatherConditions.ZoneMap {
        [
            .bitter: 20,
            .cold: 32,
            .chilly: 50,
            .pleasant: 75,
            .warm: 81,
            .hot: 90,
        ]
    }
}
