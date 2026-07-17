import CoreLocation
import MapKit

/// Google Maps 互換の zoom レベルを MapKit の表示に変換する
enum MapCameraMath {
    /// 画面幅に対応する表示範囲（メートル）— Google Maps の zoom 定義に合わせる
    static func spanMeters(zoom: Float, latitude: Double, viewportWidth: CGFloat) -> CLLocationDistance {
        let widthPx = Double(max(viewportWidth, 256))
        let metersPerPixel = 156_543.03392 * cos(latitude * .pi / 180) / pow(2.0, Double(zoom))
        return max(widthPx * metersPerPixel, 50)
    }

    static func region(center: CLLocationCoordinate2D, zoom: Float, viewportWidth: CGFloat) -> MKCoordinateRegion {
        let span = spanMeters(zoom: zoom, latitude: center.latitude, viewportWidth: viewportWidth)
        return MKCoordinateRegion(center: center, latitudinalMeters: span, longitudinalMeters: span)
    }
}
