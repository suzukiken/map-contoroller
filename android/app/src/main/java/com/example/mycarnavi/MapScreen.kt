package com.example.mycarnavi

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.Polyline
import com.google.maps.android.compose.rememberCameraPositionState
import java.time.LocalTime
import java.time.format.DateTimeFormatter

@Composable
fun MapScreen(
    viewModel: MapViewModel
) {
    val camera by viewModel.camera.collectAsState()
    val destination by viewModel.destination.collectAsState()
    val currentLocation by viewModel.currentLocation.collectAsState()
    val locationPermissionGranted by viewModel.locationPermissionGranted.collectAsState()
    val route by viewModel.route.collectAsState()
    val parkingPlaces by viewModel.parkingPlaces.collectAsState()

    var mapLoaded by remember { mutableStateOf(false) }

    val destinationMarkerState = remember { MarkerState() }

    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(
            LatLng(camera.latitude, camera.longitude),
            camera.zoom
        )
    }

    LaunchedEffect(camera, mapLoaded) {
        if (!mapLoaded) return@LaunchedEffect

        cameraPositionState.animate(
            CameraUpdateFactory.newLatLngZoom(
                LatLng(camera.latitude, camera.longitude),
                camera.zoom
            )
        )
    }

    Box(
        modifier = Modifier.fillMaxSize()
    ) {

        GoogleMap(
            modifier = Modifier.fillMaxSize(),
            cameraPositionState = cameraPositionState,
            properties = MapProperties(
                isMyLocationEnabled = locationPermissionGranted,
                isTrafficEnabled = true
            ),
            onMapLoaded = {
                mapLoaded = true
            }
        ) {
            destination?.let { dest ->
                destinationMarkerState.position =
                    LatLng(dest.latitude, dest.longitude)

                Marker(
                    state = destinationMarkerState,
                    title = "目的地"
                )
            }

            route?.let { r ->
                Polyline(
                    points = r.points,
                    color = Color(0xFF1E88E5),
                    width = 14f
                )
            }

            parkingPlaces.forEach { place ->
                key(place.latitude, place.longitude) {
                    Marker(
                        state = remember {
                            MarkerState(
                                LatLng(place.latitude, place.longitude)
                            )
                        },
                        title = place.name,
                        icon = BitmapDescriptorFactory.defaultMarker(
                            BitmapDescriptorFactory.HUE_AZURE
                        )
                    )
                }
            }
        }

        Text(
            text = "Zoom ${camera.zoom}\nLat ${camera.latitude}\nLng ${camera.longitude}" +
                    (destination?.let { "\nDest ${it.latitude}, ${it.longitude}" } ?: "") +
                    (currentLocation?.let { "\nHere ${it.latitude}, ${it.longitude}" } ?: "")
        )

        route?.let { r ->
            RouteInfoPanel(
                route = r,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(24.dp)
            )
        }
    }
}

@Composable
private fun RouteInfoPanel(
    route: RouteInfo,
    modifier: Modifier = Modifier
) {
    // ルート取得時点を基準にした到着予想時刻
    val arrivalTime = remember(route) {
        LocalTime.now()
            .plusSeconds(route.durationSeconds)
            .format(DateTimeFormatter.ofPattern("HH:mm"))
    }

    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 6.dp
    ) {
        Text(
            text = "$arrivalTime 着 ・ " +
                    "${formatDuration(route.durationSeconds)} ・ " +
                    formatDistance(route.distanceMeters),
            style = MaterialTheme.typography.titleMedium,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 12.dp)
        )
    }
}

private fun formatDuration(seconds: Long): String {
    val minutes = (seconds + 59) / 60
    val hours = minutes / 60

    return if (hours > 0) {
        "${hours}時間${minutes % 60}分"
    } else {
        "${minutes}分"
    }
}

private fun formatDistance(meters: Int): String {
    return if (meters >= 1000) {
        "%.1f km".format(meters / 1000.0)
    } else {
        "$meters m"
    }
}