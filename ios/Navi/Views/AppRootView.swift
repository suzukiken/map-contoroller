import CoreLocation
import SwiftUI

struct AppRootView: View {
    @Bindable var viewModel: MapViewModel
    let mapProxy: MapViewProxy

    var body: some View {
        MapScreen(viewModel: viewModel, mapProxy: mapProxy)
    }
}
