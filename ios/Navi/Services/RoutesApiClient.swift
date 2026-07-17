import CoreLocation
import Foundation
import OSLog

struct RoutesApiClient {
    private let apiKey: String
    private let logger = Logger(subsystem: "suzukiken.Navi", category: "RoutesApiClient")

    init(apiKey: String = MapsApiConfig.apiKey) {
        self.apiKey = apiKey
    }

    func fetchRoute(
        originLatitude: Double,
        originLongitude: Double,
        destinationLatitude: Double,
        destinationLongitude: Double
    ) async -> RouteInfo? {
        guard !apiKey.isEmpty else {
            logger.error("MAPS_API_KEY is not configured")
            return nil
        }

        let body: [String: Any] = [
            "origin": waypoint(latitude: originLatitude, longitude: originLongitude),
            "destination": waypoint(latitude: destinationLatitude, longitude: destinationLongitude),
            "travelMode": "DRIVE",
            "routingPreference": "TRAFFIC_AWARE",
        ]

        guard let url = URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body)
        else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                logger.error("Routes API error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return nil
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let routes = json["routes"] as? [[String: Any]],
                  let route = routes.first,
                  let polyline = route["polyline"] as? [String: Any],
                  let encoded = polyline["encodedPolyline"] as? String
            else {
                logger.warning("Routes API returned no routes")
                return nil
            }

            let durationRaw = route["duration"] as? String ?? "0s"
            let durationSeconds = Int64(durationRaw.dropLast()) ?? 0

            return RouteInfo(
                points: PolylineDecoder.decode(encoded),
                distanceMeters: route["distanceMeters"] as? Int ?? 0,
                durationSeconds: durationSeconds
            )
        } catch {
            logger.error("Routes API request failed: \(error.localizedDescription)")
            return nil
        }
    }

    private func waypoint(latitude: Double, longitude: Double) -> [String: Any] {
        [
            "location": [
                "latLng": [
                    "latitude": latitude,
                    "longitude": longitude,
                ],
            ],
        ]
    }
}
