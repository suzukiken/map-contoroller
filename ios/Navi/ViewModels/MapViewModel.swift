import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class MapViewModel {
    var camera = CameraState(latitude: 35.681236, longitude: 139.767125, zoom: 15)
    var destination: Destination?
    var currentLocation: CurrentLocation?
    var locationPermissionGranted = false
    var route: RouteInfo?
    var parkingPlaces: [ParkingPlace] = []
    var statusMessage: String?

    private let routesApiClient = RoutesApiClient()
    private let placesApiClient = PlacesApiClient()
    private var panTask: Task<Void, Never>?

    func setLocationPermissionGranted(_ granted: Bool) {
        locationPermissionGranted = granted
    }

    func updateCurrentLocation(latitude: Double, longitude: Double) {
        currentLocation = CurrentLocation(latitude: latitude, longitude: longitude)
    }

    func setDestinationToCenter() {
        setDestination(latitude: camera.latitude, longitude: camera.longitude)
    }

    func setDestination(latitude: Double, longitude: Double) {
        destination = Destination(latitude: latitude, longitude: longitude)
        camera.latitude = latitude
        camera.longitude = longitude
        requestRoute()
    }

    func centerOnCurrentLocation() {
        guard let location = currentLocation else { return }
        camera.latitude = location.latitude
        camera.longitude = location.longitude
    }

    func toggleParkingSearch() {
        if !parkingPlaces.isEmpty {
            parkingPlaces = []
            return
        }

        let snapshot = camera
        Task {
            parkingPlaces = await placesApiClient.searchParking(
                centerLatitude: snapshot.latitude,
                centerLongitude: snapshot.longitude
            )
        }
    }

    func startPan(_ direction: PanDirection) {
        panTask?.cancel()
        panTask = Task {
            while !Task.isCancelled {
                switch direction {
                case .west: moveWest()
                case .east: moveEast()
                case .north: moveNorth()
                case .south: moveSouth()
                }
                try? await Task.sleep(for: .milliseconds(120))
            }
        }
    }

    func stopPan() {
        panTask?.cancel()
        panTask = nil
    }

    func zoomIn() {
        camera.zoom = min(camera.zoom + 1, 21)
    }

    func zoomOut() {
        camera.zoom = max(camera.zoom - 1, 3)
    }

    func moveWest() { move(eastMeters: -200, northMeters: 0) }
    func moveEast() { move(eastMeters: 200, northMeters: 0) }
    func moveNorth() { move(eastMeters: 0, northMeters: 200) }
    func moveSouth() { move(eastMeters: 0, northMeters: -200) }

    private func move(eastMeters: Double, northMeters: Double) {
        let scale = pow(2.0, 15.0 - Double(camera.zoom))
        let dLat = northMeters * scale / 111_320.0
        let dLon = eastMeters * scale / (111_320.0 * cos(camera.latitude * .pi / 180))
        camera.latitude += dLat
        camera.longitude += dLon
    }

    private func requestRoute() {
        guard let origin = currentLocation, let destination else {
            route = nil
            return
        }

        Task {
            route = await routesApiClient.fetchRoute(
                originLatitude: origin.latitude,
                originLongitude: origin.longitude,
                destinationLatitude: destination.latitude,
                destinationLongitude: destination.longitude
            )
        }
    }
}
