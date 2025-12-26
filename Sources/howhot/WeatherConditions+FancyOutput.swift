import ConsoleKit
import Foundation

extension WeatherConditions {
    enum TempComfortZone {
        case bitter
        case cold
        case chilly
        case pleasant
        case warm
        case hot
        case sweltering

        static func zone(for temp: Temperature) -> Self {
            switch temp.toFahrenheit().reading.rounded() {
            case ..<20:
                .bitter
            case 20..<32:
                .cold
            case 32..<50:
                .chilly
            case 50..<75:
                .pleasant
            case 75..<81:
                .warm
            case 81..<90:
                .hot
            default:
                .sweltering
            }
        }

        var outputStyle: ConsoleStyle {
            switch self {
            case .bitter:
                ConsoleStyle(color: .brightBlue, isBold: true)
            case .cold:
                ConsoleStyle(color: .blue)
            case .chilly:
                ConsoleStyle(color: .cyan)
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

    func fancyOutput() -> [ConsoleText] {
        let headerFrag = ConsoleTextFragment(string: header, style: .init(color: .brightWhite, isBold: true))
        let locationLines = locationLines()
        let tempLines = temperatureLines()
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

    func temperatureLines() -> [ConsoleText] {
        let labels = ["Temperature: ", "Feels Like: ", "Coldest Reported: ", "Warmest Reported: "]
        let labelFragments = labels.map(ConsoleTextFragment.init)
        let readings = [temperature, feelsLike, localMin, localMax]
        let readingFragments = readings.map { temp in
            let zone = TempComfortZone.zone(for: temp)
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
