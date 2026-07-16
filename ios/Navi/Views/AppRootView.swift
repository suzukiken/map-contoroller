import CoreLocation
import SwiftUI

struct AppRootView: View {
    @Bindable var viewModel: MapViewModel

    var body: some View {
        MapScreen(viewModel: viewModel)
    }
}
