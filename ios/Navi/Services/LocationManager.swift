import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onLocationUpdate: ((Double, Double) -> Void)?
    var onAuthorizationChange: ((Bool) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
    }

    var isAuthorized: Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let granted = isAuthorized
            onAuthorizationChange?(granted)
            if granted {
                startUpdating()
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        Task { @MainActor in
            onLocationUpdate?(lat, lng)
        }
    }
}
