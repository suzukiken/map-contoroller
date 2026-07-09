package com.example.mycarnavi

import android.util.Log
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.PolyUtil
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject

data class RouteInfo(
    val points: List<LatLng>,
    val distanceMeters: Int,
    val durationSeconds: Long
)

class RoutesApiClient(private val apiKey: String) {

    private val client = OkHttpClient()

    /** ブロッキング呼び出しのため、IOスレッドから呼ぶこと */
    fun fetchRoute(
        originLatitude: Double,
        originLongitude: Double,
        destinationLatitude: Double,
        destinationLongitude: Double
    ): RouteInfo? {

        val requestJson = JSONObject().apply {
            put("origin", waypoint(originLatitude, originLongitude))
            put("destination", waypoint(destinationLatitude, destinationLongitude))
            put("travelMode", "DRIVE")
            // 現在の交通状況（渋滞）を考慮した所要時間を返す
            put("routingPreference", "TRAFFIC_AWARE")
        }

        val request = Request.Builder()
            .url("https://routes.googleapis.com/directions/v2:computeRoutes")
            .addHeader("X-Goog-Api-Key", apiKey)
            .addHeader(
                "X-Goog-FieldMask",
                "routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration"
            )
            .post(
                requestJson.toString()
                    .toRequestBody("application/json".toMediaType())
            )
            .build()

        client.newCall(request).execute().use { response ->

            val body = response.body?.string()

            if (!response.isSuccessful || body == null) {
                Log.e(TAG, "Routes API error: code=${response.code} body=$body")
                return null
            }

            val routes = JSONObject(body).optJSONArray("routes")

            if (routes == null || routes.length() == 0) {
                Log.w(TAG, "Routes API returned no routes: $body")
                return null
            }

            val route = routes.getJSONObject(0)

            val encodedPolyline = route
                .getJSONObject("polyline")
                .getString("encodedPolyline")

            return RouteInfo(
                points = PolyUtil.decode(encodedPolyline),
                distanceMeters = route.optInt("distanceMeters", 0),
                durationSeconds = route.optString("duration", "0s")
                    .removeSuffix("s")
                    .toLongOrNull() ?: 0L
            )
        }
    }

    private fun waypoint(latitude: Double, longitude: Double): JSONObject {
        return JSONObject().put(
            "location",
            JSONObject().put(
                "latLng",
                JSONObject()
                    .put("latitude", latitude)
                    .put("longitude", longitude)
            )
        )
    }

    companion object {
        private const val TAG = "RoutesApiClient"
    }
}
