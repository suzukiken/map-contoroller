import MapKit
import SwiftUI

struct MapKitMapView: UIViewRepresentable {
    let camera: CameraState
    let destination: Destination?
    let route: RouteInfo?
    let parkingPlaces: [ParkingPlace]
    let showsUserLocation: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsTraffic = true
        mapView.showsUserLocation = showsUserLocation
        mapView.pointOfInterestFilter = .excludingAll
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.showsUserLocation = showsUserLocation
        context.coordinator.camera = camera

        if context.coordinator.isLoaded {
            applyCamera(mapView, camera: camera)
        }

        updateAnnotations(mapView)
        updateRouteOverlay(mapView)
    }

    private func applyCamera(_ mapView: MKMapView, camera: CameraState) {
        let center = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
        let distance = altitude(forZoom: camera.zoom, latitude: camera.latitude)
        let mkCamera = MKMapCamera(lookingAtCenter: center, fromDistance: distance, pitch: 0, heading: 0)
        mapView.setCamera(mkCamera, animated: false)
    }

    private func updateAnnotations(_ mapView: MKMapView) {
        let existing = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existing)

        if let destination {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: destination.latitude,
                longitude: destination.longitude
            )
            annotation.title = "目的地"
            mapView.addAnnotation(annotation)
        }

        for place in parkingPlaces {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: place.latitude,
                longitude: place.longitude
            )
            annotation.title = place.name
            mapView.addAnnotation(annotation)
        }
    }

    private func updateRouteOverlay(_ mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        guard let route else { return }
        let validPoints = route.points.filter { CLLocationCoordinate2DIsValid($0) }
        guard validPoints.count >= 2 else { return }
        let polyline = MKPolyline(coordinates: validPoints, count: validPoints.count)
        mapView.addOverlay(polyline)
    }

    private func altitude(forZoom zoom: Float, latitude: Double) -> CLLocationDistance {
        78_106.03515625 * cos(latitude * .pi / 180) / pow(2.0, Double(zoom))
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var isLoaded = false
        var camera = CameraState(latitude: 35.681236, longitude: 139.767125, zoom: 15)

        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            guard !isLoaded else { return }
            isLoaded = true
            let center = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            let distance = 78_106.03515625 * cos(camera.latitude * .pi / 180) / pow(2.0, Double(camera.zoom))
            let mkCamera = MKMapCamera(lookingAtCenter: center, fromDistance: distance, pitch: 0, heading: 0)
            mapView.setCamera(mkCamera, animated: false)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(red: 0.12, green: 0.53, blue: 0.90, alpha: 1)
                renderer.lineWidth = 6
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
