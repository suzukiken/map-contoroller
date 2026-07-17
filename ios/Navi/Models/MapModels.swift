import CoreLocation
import Foundation

struct CameraState: Equatable {
    var latitude: Double
    var longitude: Double
    var zoom: Float
}

struct Destination: Equatable {
    var latitude: Double
    var longitude: Double
}

struct CurrentLocation: Equatable {
    var latitude: Double
    var longitude: Double
}

struct RouteInfo {
    var points: [CLLocationCoordinate2D]
    var distanceMeters: Int
    var durationSeconds: Int64
}

struct ParkingPlace: Identifiable, Equatable {
    var id: String { "\(latitude),\(longitude)" }
    var name: String
    var latitude: Double
    var longitude: Double
}

enum PanDirection {
    case west, east, north, south
}
