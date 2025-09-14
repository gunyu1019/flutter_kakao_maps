package kr.yhs.flutter_kakao_maps.controller.overlay.handler

import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelManager
import com.kakao.vectormap.label.TrackingManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString

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
      "setTrackingPosition" ->
        setTrackingRotation(arguments["rotation"]!!.asBoolean(), result::success)
    }
  }

  fun setTrackingRotation(rotation: Boolean, onSuccess: (Any?) -> Unit)

  fun startTracking(label: Label, onSuccess: (Any?) -> Unit)

  fun stopTracking(onSuccess: (Any?) -> Unit)
}
