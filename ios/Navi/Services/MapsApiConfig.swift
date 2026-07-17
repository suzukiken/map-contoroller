import Foundation

enum MapsApiConfig {
    static var apiKey: String {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String else {
            return ""
        }
        let key = raw.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        guard !key.isEmpty, key != "YOUR_GOOGLE_MAPS_API_KEY" else {
            return ""
        }
        return key
    }
}
