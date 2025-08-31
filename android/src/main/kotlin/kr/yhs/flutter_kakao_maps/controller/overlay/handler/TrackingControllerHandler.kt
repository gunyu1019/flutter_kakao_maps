package kr.yhs.flutter_kakao_maps.controller.overlay.handler

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asDotPoints
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asMapPoints
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolygonOption
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolygonStylesSet
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolylineOption
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asPolylineStylesSet
import kr.yhs.flutter_kakao_maps.converter.ShapeTypeConverter.asShapeLayerOption
import com.kakao.vectormap.label.TrackingManager
import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelManager

interface TrackingControllerHandler {
  val trackingManager: TrackingManager?

  val labelManager: LabelManager?
 
  fun trackingHandle(call: MethodCall, result: MethodChannel.Result) {
    val arguments = call.arguments!!.asMap<Any?>()
    if (trackingManager == null) {
      throw NullPointerException("TrackingManager is null.")
    }

    when (call.method) {
      "startTracking" -> {
        val labelLayer = labelManager!!.getLayer(arguments["layerId"]!!.asString())
        val label = labelLayer.getLabel(arguments["poiId"]!!.asString())
        startTracking(label, result::success)
      }
      "stopTracking" -> stopTracking(result::success)
      "setTrackingPosition" -> setTrackingRotation(arguments["rotation"]!!.asBoolean(), result::success)
    }
  }
  
  fun setTrackingRotation(rotation: Boolean, onSuccess: (Any?) -> Unit)

  fun startTracking(label: Label, onSuccess: (Any?) -> Unit)

  fun stopTracking(onSuccess: (Any?) -> Unit)
}
