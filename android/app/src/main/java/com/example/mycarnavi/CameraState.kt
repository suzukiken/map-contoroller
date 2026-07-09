package com.example.mycarnavi

data class CameraState(
    val latitude: Double,
    val longitude: Double,
    val zoom: Float
)

data class Destination(
    val latitude: Double,
    val longitude: Double
)

data class CurrentLocation(
    val latitude: Double,
    val longitude: Double
)