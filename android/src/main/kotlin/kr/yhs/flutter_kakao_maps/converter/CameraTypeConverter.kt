package kr.yhs.flutter_kakao_maps.converter

import com.kakao.vectormap.LatLng
import com.kakao.vectormap.camera.CameraAnimation
import com.kakao.vectormap.camera.CameraPosition
import com.kakao.vectormap.camera.CameraUpdate
import com.kakao.vectormap.camera.CameraUpdateFactory
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asDouble
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap

object CameraTypeConverter {
  fun Any.asLatLng(): LatLng =
    asMap<Double>().let { rawPayload: Map<String, Double> ->
      LatLng.from(rawPayload["latitude"]!!, rawPayload["longitude"]!!)
    }

  fun LatLng.toMessageable(): Map<String, Double> =
    mapOf("latitude" to latitude, "longitude" to longitude)

  fun Any.asCameraPosition(): CameraPosition =
    asMap<Any>().let { rawPayload: Map<String, Any> ->
      CameraPosition.from(
        rawPayload["latitude"] as Double,
        rawPayload["longitude"] as Double,
        rawPayload["zoomLevel"] as Int? ?: -1,
        rawPayload["tiltAngle"] as Double? ?: -1.0,
        rawPayload["rotationAngle"] as Double? ?: -1.0,
        rawPayload["height"] as Double? ?: -1.0,
      )
    }

  fun CameraPosition.toMessageable(): Map<String, Any> =
    mapOf(
      "latitude" to position.latitude,
      "longitude" to position.longitude,
      "zoomLevel" to zoomLevel,
      "tiltAngle" to tiltAngle,
      "rotationAngle" to rotationAngle,
      "height" to height,
    )

  fun Any.asCameraAnimation(): CameraAnimation =
    asMap<Any>().let { rawPayload: Map<String, Any?> ->
      CameraAnimation.from(
        rawPayload["duration"] as Int,
        rawPayload["autoElevation"] as Boolean? ?: false,
        rawPayload["isConsecutive"] as Boolean? ?: false,
      )
    }

  fun Any.asCameraUpdate(): CameraUpdate =
    asMap<Any>().let { rawPayload: Map<String, Any> ->
      val type = rawPayload["type"]!!.asInt()
      val zoomLevel = rawPayload.getOrDefault("zoomLevel", -1).asInt()
      val angle = rawPayload.getOrDefault("angle", -1.0).asDouble()

      when (type) {
        CameraUpdateFactory.NewCenterPoint ->
          CameraUpdateFactory.newCenterPosition(rawPayload.asLatLng(), zoomLevel)
        CameraUpdateFactory.NewCameraPos ->
          CameraUpdateFactory.newCameraPosition(rawPayload.asCameraPosition())
        CameraUpdateFactory.ZoomTo -> CameraUpdateFactory.zoomTo(zoomLevel)
        CameraUpdateFactory.ZoomIn -> CameraUpdateFactory.zoomIn()
        CameraUpdateFactory.ZoomOut -> CameraUpdateFactory.zoomOut()
        CameraUpdateFactory.Rotate -> CameraUpdateFactory.rotateTo(angle)
        CameraUpdateFactory.Tilt -> CameraUpdateFactory.tiltTo(angle)
        CameraUpdateFactory.FitMapPoints -> {
          @Suppress("UNCHECKED_CAST") val points = (rawPayload["points"] as List<Map<String, Any>>)
          val padding = rawPayload.getOrDefault("padding", 0).asInt()
          CameraUpdateFactory.fitMapPoints(
            points.map { point -> point.asLatLng() }.toTypedArray(),
            padding,
            zoomLevel,
          )
        }
        else -> throw NotImplementedError("Wrong CameraUpdate type")
      }
    }
}
