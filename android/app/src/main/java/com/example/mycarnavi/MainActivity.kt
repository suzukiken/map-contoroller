package com.example.mycarnavi

import android.Manifest
import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Geocoder
import android.os.Bundle
import android.os.Looper
import android.speech.RecognizerIntent
import android.util.Log
import android.view.KeyEvent
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Scaffold
import androidx.compose.ui.Modifier
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.example.mycarnavi.ui.theme.MyCarNaviTheme
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Locale

class MainActivity : ComponentActivity() {

    private val viewModel: MapViewModel by viewModels()

    private lateinit var fusedLocationClient: FusedLocationProviderClient

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            result.lastLocation?.let { location ->
                viewModel.updateCurrentLocation(
                    location.latitude,
                    location.longitude
                )
            }
        }
    }

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { grants ->
        if (grants.values.any { it }) {
            viewModel.setLocationPermissionGranted(true)
            startLocationUpdates()
        }
    }

    private val speechLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val spokenText = result.data
            ?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            ?.firstOrNull()

        if (result.resultCode == RESULT_OK && spokenText != null) {
            searchDestinationByName(spokenText)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        fusedLocationClient =
            LocationServices.getFusedLocationProviderClient(this)

        if (hasLocationPermission()) {
            viewModel.setLocationPermissionGranted(true)
        } else {
            permissionLauncher.launch(
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                )
            )
        }

        enableEdgeToEdge()

        setContent {
            MyCarNaviTheme {
                Scaffold(
                    modifier = Modifier.fillMaxSize()
                ) {
                    MapScreen(viewModel)
                }
            }
        }
    }

    override fun onStart() {
        super.onStart()
        if (hasLocationPermission()) {
            startLocationUpdates()
        }
    }

    override fun onStop() {
        super.onStop()
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(
                    this, Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
    }

    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            2000L
        ).build()

        fusedLocationClient.requestLocationUpdates(
            request,
            locationCallback,
            Looper.getMainLooper()
        )
    }

    private fun startVoiceInput() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "ja-JP")
            putExtra(RecognizerIntent.EXTRA_PROMPT, "目的地を話してください")
        }

        try {
            speechLauncher.launch(intent)
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(
                this,
                "音声認識が利用できません",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun searchDestinationByName(name: String) {
        lifecycleScope.launch(Dispatchers.IO) {

            val address = try {
                @Suppress("DEPRECATION")
                Geocoder(this@MainActivity, Locale.JAPAN)
                    .getFromLocationName(name, 1)
                    ?.firstOrNull()
            } catch (e: Exception) {
                Log.e("MainActivity", "Geocoding failed for: $name", e)
                null
            }

            withContext(Dispatchers.Main) {
                if (address != null) {
                    viewModel.setDestination(address.latitude, address.longitude)
                    Toast.makeText(
                        this@MainActivity,
                        "目的地: $name",
                        Toast.LENGTH_SHORT
                    ).show()
                } else {
                    Toast.makeText(
                        this@MainActivity,
                        "「$name」が見つかりませんでした",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {

        if (event.action == KeyEvent.ACTION_DOWN) {

            when (event.keyCode) {

                KeyEvent.KEYCODE_DPAD_LEFT ->
                    viewModel.moveWest()

                KeyEvent.KEYCODE_DPAD_RIGHT ->
                    viewModel.moveEast()

                KeyEvent.KEYCODE_DPAD_UP ->
                    viewModel.moveNorth()

                KeyEvent.KEYCODE_DPAD_DOWN ->
                    viewModel.moveSouth()

                KeyEvent.KEYCODE_PAGE_UP ->
                    viewModel.zoomIn()

                KeyEvent.KEYCODE_PAGE_DOWN ->
                    viewModel.zoomOut()

                KeyEvent.KEYCODE_ENTER,
                KeyEvent.KEYCODE_DPAD_CENTER ->
                    viewModel.setDestinationToCenter()

                KeyEvent.KEYCODE_SPACE ->
                    viewModel.centerOnCurrentLocation()

                KeyEvent.KEYCODE_V,
                KeyEvent.KEYCODE_VOICE_ASSIST ->
                    startVoiceInput()

                KeyEvent.KEYCODE_P ->
                    viewModel.toggleParkingSearch()
            }
        }

        return super.dispatchKeyEvent(event)
    }
}