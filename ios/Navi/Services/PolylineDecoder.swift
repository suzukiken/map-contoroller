import CoreLocation
import Foundation

enum PolylineDecoder {
    /// Google encoded polyline → 座標列
    static func decode(_ encoded: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var index = encoded.startIndex
        var lat = 0
        var lng = 0

        while index < encoded.endIndex {
            var result = 0
            var shift = 0
            var byte: Int

            repeat {
                guard index < encoded.endIndex else { return coordinates }
                byte = Int(encoded[index].asciiValue! - 63)
                index = encoded.index(after: index)
                result |= (byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lat += deltaLat

            result = 0
            shift = 0

            repeat {
                guard index < encoded.endIndex else { return coordinates }
                byte = Int(encoded[index].asciiValue! - 63)
                index = encoded.index(after: index)
                result |= (byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lng += deltaLng

            coordinates.append(
                CLLocationCoordinate2D(
                    latitude: Double(lat) / 1e5,
                    longitude: Double(lng) / 1e5
                )
            )
        }

        return coordinates
    }
}
