import Foundation
import OSLog

struct PlacesApiClient {
    private let apiKey: String
    private let logger = Logger(subsystem: "suzukiken.Navi", category: "PlacesApiClient")

    init(apiKey: String = MapsApiConfig.apiKey) {
        self.apiKey = apiKey
    }

    func searchParking(
        centerLatitude: Double,
        centerLongitude: Double,
        radiusMeters: Double = 1000
    ) async -> [ParkingPlace] {
        guard !apiKey.isEmpty else {
            logger.error("MAPS_API_KEY is not configured")
            return []
        }

        let body: [String: Any] = [
            "includedTypes": ["parking"],
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": centerLatitude,
                        "longitude": centerLongitude,
                    ],
                    "radius": radiusMeters,
                ],
            ],
        ]

        guard let url = URL(string: "https://places.googleapis.com/v1/places:searchNearby"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body)
        else {
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "places.displayName,places.location",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                logger.error("Places API error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return []
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let places = json["places"] as? [[String: Any]]
            else {
                return []
            }

            return places.compactMap { place in
                guard let location = place["location"] as? [String: Any],
                      let lat = location["latitude"] as? Double,
                      let lng = location["longitude"] as? Double
                else {
                    return nil
                }

                let name = (place["displayName"] as? [String: Any])?["text"] as? String ?? "駐車場"
                return ParkingPlace(name: name, latitude: lat, longitude: lng)
            }
        } catch {
            logger.error("Places API request failed: \(error.localizedDescription)")
            return []
        }
    }
}
