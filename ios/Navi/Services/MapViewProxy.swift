import CoreLocation
import MapKit

/// MKMapView の表示中心を ViewModel から参照するためのブリッジ
final class MapViewProxy {
    weak var mapView: MKMapView?

    var visibleCenter: CLLocationCoordinate2D? {
        mapView?.centerCoordinate
    }
}
