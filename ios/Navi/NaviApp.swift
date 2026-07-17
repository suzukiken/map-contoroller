import CoreLocation
import SwiftUI

@main
struct NaviApp: App {
    @State private var viewModel = MapViewModel()
    @State private var locationManager = LocationManager()
    @State private var speechManager = SpeechInputManager()

    var body: some Scene {
        WindowGroup {
            KeyHandlingRootView(viewModel: viewModel, onVoiceInput: startVoiceInput) {
                AppRootView(viewModel: viewModel)
            }
            .onAppear {
                setupLocation()
            }
        }
    }

    private func setupLocation() {
        locationManager.onLocationUpdate = { lat, lng in
            viewModel.updateCurrentLocation(latitude: lat, longitude: lng)
        }
        locationManager.onAuthorizationChange = { granted in
            viewModel.setLocationPermissionGranted(granted)
        }

        if locationManager.isAuthorized {
            viewModel.setLocationPermissionGranted(true)
            locationManager.startUpdating()
        } else {
            locationManager.requestPermission()
        }
    }

    private func startVoiceInput() {
        Task {
            let speechAuthorized = await speechManager.requestAuthorization()
            guard speechAuthorized else {
                viewModel.statusMessage = "音声認識の権限がありません"
                return
            }

            viewModel.statusMessage = "話してください…"
            do {
                let spoken = try await speechManager.transcribe()
                guard !spoken.isEmpty else {
                    viewModel.statusMessage = "音声を認識できませんでした"
                    return
                }
                await searchDestination(spoken)
            } catch {
                viewModel.statusMessage = "音声認識が利用できません"
            }
        }
    }

    private func searchDestination(_ name: String) async {
        if let coordinate = await GeocoderService.search(name) {
            viewModel.setDestination(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            viewModel.statusMessage = "目的地: \(name)"
        } else {
            viewModel.statusMessage = "「\(name)」が見つかりませんでした"
        }
    }
}
