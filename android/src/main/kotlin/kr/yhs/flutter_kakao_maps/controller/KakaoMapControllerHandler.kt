package kr.yhs.flutter_kakao_maps.controller

import com.kakao.vectormap.GestureType
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.MapOverlay
import com.kakao.vectormap.MapType
import com.kakao.vectormap.camera.CameraAnimation
import com.kakao.vectormap.camera.CameraUpdate
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.asCameraAnimation
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.asCameraUpdate
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.asLatLng
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asFloat
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asList
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString
import kr.yhs.flutter_kakao_maps.model.DefaultGUIType

interface KakaoMapControllerHandler {
  fun handle(call: MethodCall, result: MethodChannel.Result) =
    when (call.method) {
      "getCameraPosition" -> getCameraPosition(result::success)
      "moveCamera" -> {
        val arguments = call.arguments?.asMap<Any?>()
        val animation = arguments?.get("cameraAnimation")?.asCameraAnimation()
        val camera = arguments?.get("cameraUpdate")!!.asCameraUpdate()
        moveCamera(camera, animation, result::success)
      }
      "setGestureEnable" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        val gestureType = GestureType.getEnum(arguments["gestureType"]!!.asInt())
        val enable = arguments["enable"]!!.asBoolean()
        setGestureEnable(gestureType, enable, result::success)
      }
      "setEventHandler" -> setEventHandler(call.arguments!!.asInt())
      "fromScreenPoint" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        fromScreenPoint(arguments["x"]!!.asInt(), arguments["y"]!!.asInt(), result::success)
      }
      "toScreenPoint" -> toScreenPoint(call.arguments!!.asLatLng(), result::success)
      "clearCache" -> clearCache(result::success)
      "clearDiskCache" -> clearDiskCache(result::success)
      "canPositionVisible" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        canPositionVisible(
          arguments["zoomLevel"]!!.asInt(),
          arguments["position"]!!.asList<Any>().map { it.asLatLng() },
          result::success,
        )
      }
      "changeMapType" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        changeMapType(arguments["mapType"]!!.toString().let(MapType::getEnum), result::success)
      }
      "overlayVisible" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        overlayVisible(
          arguments["overlayType"]!!.asString().let(MapOverlay::getEnum),
          arguments["visible"]?.asBoolean() ?: true,
          result::success,
        )
      }
      "getBuildingHeightScale" -> getBuildingHeightScale(result::success)
      "setBuildingHeightScale" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        setBuildingHeightScale(arguments["scale"]!!.asFloat(), result::success)
      }
      "defaultGUIvisible" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        val guiType =
          DefaultGUIType.values().filter { it.value == arguments["type"]!!.asString() }.first()
        defaultGUIvisible(guiType, arguments["visible"]!!.asBoolean(), result::success)
      }
      "defaultGUIposition" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        val guiType =
          DefaultGUIType.values().filter { it.value == arguments["type"]!!.asString() }.first()
        defaultGUIposition(
          guiType,
          arguments["gravity"]!!.asInt(),
          arguments["x"]!!.asFloat(),
          arguments["y"]!!.asFloat(),
          result::success,
        )
      }
      "scaleAutohide" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        scaleAutohide(arguments["autohide"]!!.asBoolean(), result::success)
      }
      "scaleAnimationTime" -> {
        val arguments = call.arguments!!.asMap<Any?>()
        scaleAnimationTime(
          arguments["fadeIn"]!!.asInt(),
          arguments["fadeOut"]!!.asInt(),
          arguments["retention"]!!.asInt(),
          result::success,
        )
      }
      "pause" -> pause(result::success)
      "resume" -> resume(result::success)
      "finish" -> finish(result::success)
      else -> result.notImplemented()
    }

  fun getCameraPosition(onSuccess: (cameraPosition: Map<String, Any>) -> Unit)

  fun moveCamera(
    cameraUpdate: CameraUpdate,
    cameraAnimation: CameraAnimation?,
    onSuccess: (Any?) -> Unit,
  )

  fun setGestureEnable(gestureType: GestureType, enable: Boolean, onSuccess: (Any?) -> Unit)

  fun setEventHandler(event: Int)

  fun fromScreenPoint(x: Int, y: Int, onSuccess: (Map<String, Any>?) -> Unit)

  fun toScreenPoint(position: LatLng, onSuccess: (Map<String, Any>?) -> Unit)

  fun clearCache(onSuccess: (Any?) -> Unit)

  fun clearDiskCache(onSuccess: (Any?) -> Unit)

  fun canPositionVisible(zoomLevel: Int, position: List<LatLng>, onSuccess: (Boolean) -> Unit)

  fun changeMapType(mapType: MapType, onSuccess: (Any?) -> Unit)

  fun overlayVisible(overlayType: MapOverlay, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun getBuildingHeightScale(onSuccess: (Float) -> Unit)

  fun setBuildingHeightScale(scale: Float, onSuccess: (Any?) -> Unit)

  fun defaultGUIvisible(type: DefaultGUIType, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun defaultGUIposition(
    type: DefaultGUIType,
    gravity: Int,
    x: Float,
    y: Float,
    onSuccess: (Any?) -> Unit,
  )

  fun scaleAutohide(autohide: Boolean, onSuccess: (Any?) -> Unit)

  fun scaleAnimationTime(fadeIn: Int, fadeOut: Int, retention: Int, onSuccess: (Any?) -> Unit)

  fun pause(onSuccess: (Any?) -> Unit)

  fun resume(onSuccess: (Any?) -> Unit)

  fun finish(onSuccess: (Any?) -> Unit)
}
