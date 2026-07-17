import MapKit
import SwiftUI

struct MapKitMapView: UIViewRepresentable {
    let camera: CameraState
    let destination: Destination?
    let route: RouteInfo?
    let parkingPlaces: [ParkingPlace]
    let showsUserLocation: Bool
    let mapProxy: MapViewProxy

    func makeCoordinator() -> Coordinator {
        Coordinator(mapProxy: mapProxy)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsTraffic = true
        mapView.showsUserLocation = showsUserLocation
        mapView.pointOfInterestFilter = .excludingAll
        // コントローラー操作のみ（タッチで地図がずれると Enter の中心と不一致になる）
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        context.coordinator.attach(mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.showsUserLocation = showsUserLocation
        context.coordinator.camera = camera

        if context.coordinator.isLoaded {
            Self.applyCamera(mapView, camera: camera)
        }

        context.coordinator.updateDestination(destination)
        context.coordinator.updateParkingPlaces(parkingPlaces)
        updateRouteOverlay(mapView)
    }

    private static func applyCamera(_ mapView: MKMapView, camera: CameraState) {
        let center = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
        let region = MapCameraMath.region(
            center: center,
            zoom: camera.zoom,
            viewportWidth: mapView.bounds.width
        )
        mapView.setRegion(region, animated: false)
    }

    private func updateRouteOverlay(_ mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        guard let route else { return }
        let validPoints = route.points.filter { CLLocationCoordinate2DIsValid($0) }
        guard validPoints.count >= 2 else { return }
        let polyline = MKPolyline(coordinates: validPoints, count: validPoints.count)
        mapView.addOverlay(polyline)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var isLoaded = false
        var camera = CameraState(latitude: 35.681236, longitude: 139.767125, zoom: 15)
        private let mapProxy: MapViewProxy
        private weak var mapView: MKMapView?
        private var destinationAnnotation: MKPointAnnotation?
        private var parkingAnnotations: [MKPointAnnotation] = []

        init(mapProxy: MapViewProxy) {
            self.mapProxy = mapProxy
        }

        func attach(_ mapView: MKMapView) {
            self.mapView = mapView
            mapProxy.mapView = mapView
        }

        func updateDestination(_ destination: Destination?) {
            guard let mapView else { return }
            if let destinationAnnotation {
                mapView.removeAnnotation(destinationAnnotation)
                self.destinationAnnotation = nil
            }
            guard let destination else { return }
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: destination.latitude,
                longitude: destination.longitude
            )
            annotation.title = "目的地"
            destinationAnnotation = annotation
            mapView.addAnnotation(annotation)
        }

        func updateParkingPlaces(_ places: [ParkingPlace]) {
            guard let mapView else { return }
            mapView.removeAnnotations(parkingAnnotations)
            parkingAnnotations = places.map { place in
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                )
                annotation.title = place.name
                return annotation
            }
            mapView.addAnnotations(parkingAnnotations)
        }

        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            guard !isLoaded else { return }
            isLoaded = true
            MapKitMapView.applyCamera(mapView, camera: camera)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let identifier = "Pin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.canShowCallout = true
            if annotation === destinationAnnotation {
                view.markerTintColor = .systemRed
                view.glyphImage = nil
            } else {
                view.markerTintColor = .systemTeal
            }
            return view
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
