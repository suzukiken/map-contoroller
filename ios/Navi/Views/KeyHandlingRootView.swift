import CoreLocation
import MapKit
import SwiftUI
import UIKit

struct KeyHandlingRootView: UIViewControllerRepresentable {
    let content: AnyView
    let viewModel: MapViewModel
    let onVoiceInput: () -> Void

    init<V: View>(viewModel: MapViewModel, onVoiceInput: @escaping () -> Void, @ViewBuilder content: () -> V) {
        self.viewModel = viewModel
        self.onVoiceInput = onVoiceInput
        self.content = AnyView(content())
    }

    func makeUIViewController(context: Context) -> KeyHandlingViewController {
        let controller = KeyHandlingViewController(rootView: content)
        controller.viewModel = viewModel
        controller.onVoiceInput = onVoiceInput
        return controller
    }

    func updateUIViewController(_ controller: KeyHandlingViewController, context: Context) {
        controller.viewModel = viewModel
        controller.onVoiceInput = onVoiceInput
        controller.updateRootView(content)
    }
}

final class KeyHandlingViewController: UIViewController {
    private var hostingController: UIHostingController<AnyView>?
    var viewModel: MapViewModel?
    var onVoiceInput: (() -> Void)?

    init(rootView: AnyView) {
        super.init(nibName: nil, bundle: nil)
        let hosting = UIHostingController(rootView: rootView)
        hostingController = hosting
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateRootView(_ view: AnyView) {
        hostingController?.rootView = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let hostingController else { return }
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isFirstResponder {
            becomeFirstResponder()
        }
    }

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        [
            keyCommand(input: "\r", action: #selector(handleEnter)),
            keyCommand(input: "\n", action: #selector(handleEnter)),
            keyCommand(input: " ", action: #selector(handleSpace)),
            keyCommand(input: "v", action: #selector(handleVoice)),
            keyCommand(input: "V", action: #selector(handleVoice)),
            keyCommand(input: "p", action: #selector(handleParking)),
            keyCommand(input: "P", action: #selector(handleParking)),
            keyCommand(input: UIKeyCommand.inputPageUp, action: #selector(handlePageUp)),
            keyCommand(input: UIKeyCommand.inputPageDown, action: #selector(handlePageDown)),
            keyCommand(input: "+", action: #selector(handlePageUp)),
            keyCommand(input: "=", action: #selector(handlePageUp)),
            keyCommand(input: "-", action: #selector(handlePageDown)),
        ]
    }

    private func keyCommand(input: String, action: Selector) -> UIKeyCommand {
        let command = UIKeyCommand(input: input, modifierFlags: [], action: action)
        command.wantsPriorityOverSystemBehavior = true
        return command
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var handled = false
        for press in presses {
            guard let key = press.key else { continue }
            switch key.keyCode {
            case .keyboardLeftArrow:
                viewModel?.startPan(.west)
                handled = true
            case .keyboardRightArrow:
                viewModel?.startPan(.east)
                handled = true
            case .keyboardUpArrow:
                viewModel?.startPan(.north)
                handled = true
            case .keyboardDownArrow:
                viewModel?.startPan(.south)
                handled = true
            case .keyboardReturnOrEnter:
                viewModel?.setDestinationToCenter()
                handled = true
            case .keyboardSpacebar:
                viewModel?.centerOnCurrentLocation()
                handled = true
            case .keyboardPageUp:
                viewModel?.zoomIn()
                handled = true
            case .keyboardPageDown:
                viewModel?.zoomOut()
                handled = true
            case .keyboardEqualSign:
                viewModel?.zoomIn()
                handled = true
            case .keyboardHyphen:
                viewModel?.zoomOut()
                handled = true
            default:
                break
            }
        }
        if !handled {
            super.pressesBegan(presses, with: event)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var handled = false
        for press in presses {
            guard let key = press.key else { continue }
            switch key.keyCode {
            case .keyboardLeftArrow, .keyboardRightArrow, .keyboardUpArrow, .keyboardDownArrow:
                viewModel?.stopPan()
                handled = true
            default:
                break
            }
        }
        if !handled {
            super.pressesEnded(presses, with: event)
        }
    }

    @objc private func handleEnter() { viewModel?.setDestinationToCenter() }
    @objc private func handleSpace() { viewModel?.centerOnCurrentLocation() }
    @objc private func handleVoice() { onVoiceInput?() }
    @objc private func handleParking() { viewModel?.toggleParkingSearch() }
    @objc private func handlePageUp() { viewModel?.zoomIn() }
    @objc private func handlePageDown() { viewModel?.zoomOut() }
}

enum GeocoderService {
    static func search(_ query: String) async -> CLLocationCoordinate2D? {
        await withCheckedContinuation { continuation in
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
                span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
            )
            MKLocalSearch(request: request).start { response, _ in
                continuation.resume(returning: response?.mapItems.first?.placemark.coordinate)
            }
        }
    }
}
