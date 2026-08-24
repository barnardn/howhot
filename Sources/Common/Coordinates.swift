import Foundation

public struct Coordinates: Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Coordinates: CustomStringConvertible {
    public var description: String {
        String(format: "Lat: %.8f, Lon: %.8f", latitude, longitude)
    }
}
