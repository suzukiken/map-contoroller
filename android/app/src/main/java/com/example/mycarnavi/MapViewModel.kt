package com.example.mycarnavi

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class MapViewModel : ViewModel() {

    private val routesApiClient = RoutesApiClient(BuildConfig.MAPS_API_KEY)

    private val placesApiClient = PlacesApiClient(BuildConfig.MAPS_API_KEY)

    private val _camera = MutableStateFlow(
        CameraState(
            latitude = 35.681236,
            longitude = 139.767125,
            zoom = 15f
        )
    )

    val camera: StateFlow<CameraState> = _camera

    private val _destination = MutableStateFlow<Destination?>(null)

    val destination: StateFlow<Destination?> = _destination

    fun setDestinationToCenter() {
        val camera = _camera.value
        setDestination(camera.latitude, camera.longitude)
    }

    fun setDestination(latitude: Double, longitude: Double) {
        _destination.value = Destination(
            latitude = latitude,
            longitude = longitude
        )
        // 目的地を画面中心に表示する
        _camera.value = _camera.value.copy(
            latitude = latitude,
            longitude = longitude
        )
        requestRoute()
    }

    private val _route = MutableStateFlow<RouteInfo?>(null)

    val route: StateFlow<RouteInfo?> = _route

    private val _parkingPlaces = MutableStateFlow<List<ParkingPlace>>(emptyList())

    val parkingPlaces: StateFlow<List<ParkingPlace>> = _parkingPlaces

    /** 駐車場マーカーの表示切り替え。非表示なら検索して表示、表示中なら消す */
    fun toggleParkingSearch() {
        if (_parkingPlaces.value.isNotEmpty()) {
            _parkingPlaces.value = emptyList()
            return
        }

        val camera = _camera.value

        viewModelScope.launch(Dispatchers.IO) {
            _parkingPlaces.value = try {
                placesApiClient.searchParking(
                    centerLatitude = camera.latitude,
                    centerLongitude = camera.longitude
                )
            } catch (e: Exception) {
                Log.e("MapViewModel", "Failed to search parking", e)
                emptyList()
            }
        }
    }

    private fun requestRoute() {
        val origin = _currentLocation.value
        val destination = _destination.value

        if (origin == null || destination == null) {
            _route.value = null
            return
        }

        viewModelScope.launch(Dispatchers.IO) {
            _route.value = try {
                routesApiClient.fetchRoute(
                    originLatitude = origin.latitude,
                    originLongitude = origin.longitude,
                    destinationLatitude = destination.latitude,
                    destinationLongitude = destination.longitude
                )
            } catch (e: Exception) {
                Log.e("MapViewModel", "Failed to fetch route", e)
                null
            }
        }
    }

    private val _currentLocation = MutableStateFlow<CurrentLocation?>(null)

    val currentLocation: StateFlow<CurrentLocation?> = _currentLocation

    private val _locationPermissionGranted = MutableStateFlow(false)

    val locationPermissionGranted: StateFlow<Boolean> = _locationPermissionGranted

    fun setLocationPermissionGranted(granted: Boolean) {
        _locationPermissionGranted.value = granted
    }

    fun updateCurrentLocation(latitude: Double, longitude: Double) {
        _currentLocation.value = CurrentLocation(latitude, longitude)
    }

    fun centerOnCurrentLocation() {
        val location = _currentLocation.value ?: return
        _camera.value = _camera.value.copy(
            latitude = location.latitude,
            longitude = location.longitude
        )
    }

    fun moveWest() {
        move(-200.0, 0.0)
    }

    fun moveEast() {
        move(200.0, 0.0)
    }

    fun moveNorth() {
        move(0.0, 200.0)
    }

    fun moveSouth() {
        move(0.0, -200.0)
    }

    fun zoomIn() {
        _camera.value = _camera.value.copy(
            zoom = (_camera.value.zoom + 1f).coerceAtMost(21f)
        )
    }

    fun zoomOut() {
        _camera.value = _camera.value.copy(
            zoom = (_camera.value.zoom - 1f).coerceAtLeast(3f)
        )
    }

    private fun move(eastMeters: Double, northMeters: Double) {

        val camera = _camera.value

        // ズームが1段階下がると表示範囲が約2倍になるため、
        // 移動量も2倍にして画面上の移動量を一定に保つ（zoom=15で基準の200m）
        val scale = Math.pow(2.0, (15.0 - camera.zoom))

        val dLat = northMeters * scale / 111320.0

        val dLon = eastMeters * scale /
                (111320.0 * kotlin.math.cos(Math.toRadians(camera.latitude)))

        _camera.value = camera.copy(
            latitude = camera.latitude + dLat,
            longitude = camera.longitude + dLon
        )
    }
}