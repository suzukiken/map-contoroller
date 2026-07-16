import CoreLocation
import SwiftUI

struct MapScreen: View {
    @Bindable var viewModel: MapViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            MapKitMapView(
                camera: viewModel.camera,
                destination: viewModel.destination,
                route: viewModel.route,
                parkingPlaces: viewModel.parkingPlaces,
                showsUserLocation: viewModel.locationPermissionGranted
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                debugText
                if let message = viewModel.statusMessage {
                    Text(message)
                        .font(.callout)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
                if let route = viewModel.route {
                    RouteInfoPanel(route: route)
                        .padding(.bottom, 24)
                }
            }
            .padding()
        }
    }

    private var debugText: some View {
        let dest = viewModel.destination.map { "\($0.latitude), \($0.longitude)" } ?? "-"
        let here = viewModel.currentLocation.map { "\($0.latitude), \($0.longitude)" } ?? "-"
        return Text(
            """
            Zoom \(String(format: "%.1f", viewModel.camera.zoom))
            Lat \(viewModel.camera.latitude)
            Lng \(viewModel.camera.longitude)
            Dest \(dest)
            Here \(here)
            """
        )
        .font(.caption.monospaced())
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
