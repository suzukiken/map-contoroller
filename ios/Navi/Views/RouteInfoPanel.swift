import SwiftUI

struct RouteInfoPanel: View {
    let route: RouteInfo

    var body: some View {
        Text("\(arrivalTime) 着 ・ \(formatDuration(route.durationSeconds)) ・ \(formatDistance(route.distanceMeters))")
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
    }

    private var arrivalTime: String {
        let arrival = Date().addingTimeInterval(TimeInterval(route.durationSeconds))
        return arrival.formatted(.dateTime.hour().minute())
    }

    private func formatDuration(_ seconds: Int64) -> String {
        let minutes = (seconds + 59) / 60
        let hours = minutes / 60
        if hours > 0 {
            return "\(hours)時間\(minutes % 60)分"
        }
        return "\(minutes)分"
    }

    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", Double(meters) / 1000.0)
        }
        return "\(meters) m"
    }
}
