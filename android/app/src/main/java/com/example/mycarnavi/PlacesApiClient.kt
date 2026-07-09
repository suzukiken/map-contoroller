package com.example.mycarnavi

import android.util.Log
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject

data class ParkingPlace(
    val name: String,
    val latitude: Double,
    val longitude: Double
)

class PlacesApiClient(private val apiKey: String) {

    private val client = OkHttpClient()

    /** ブロッキング呼び出しのため、IOスレッドから呼ぶこと */
    fun searchParking(
        centerLatitude: Double,
        centerLongitude: Double,
        radiusMeters: Double = 1000.0
    ): List<ParkingPlace> {

        val requestJson = JSONObject().apply {
            put("includedTypes", JSONArray().put("parking"))
            put("maxResultCount", 20)
            put("locationRestriction", JSONObject().put(
                "circle", JSONObject()
                    .put("center", JSONObject()
                        .put("latitude", centerLatitude)
                        .put("longitude", centerLongitude))
                    .put("radius", radiusMeters)
            ))
        }

        val request = Request.Builder()
            .url("https://places.googleapis.com/v1/places:searchNearby")
            .addHeader("X-Goog-Api-Key", apiKey)
            .addHeader(
                "X-Goog-FieldMask",
                "places.displayName,places.location"
            )
            .post(
                requestJson.toString()
                    .toRequestBody("application/json".toMediaType())
            )
            .build()

        client.newCall(request).execute().use { response ->

            val body = response.body?.string()

            if (!response.isSuccessful || body == null) {
                Log.e(TAG, "Places API error: code=${response.code} body=$body")
                return emptyList()
            }

            val places = JSONObject(body).optJSONArray("places")
                ?: return emptyList()

            return (0 until places.length()).mapNotNull { i ->
                val place = places.getJSONObject(i)
                val location = place.optJSONObject("location")
                    ?: return@mapNotNull null

                val lat = location.optDouble("latitude", Double.NaN)
                val lng = location.optDouble("longitude", Double.NaN)
                if (lat.isNaN() || lng.isNaN()) return@mapNotNull null

                ParkingPlace(
                    name = place.optJSONObject("displayName")
                        ?.optString("text")
                        ?: "駐車場",
                    latitude = lat,
                    longitude = lng
                )
            }
        }
    }

    companion object {
        private const val TAG = "PlacesApiClient"
    }
}
