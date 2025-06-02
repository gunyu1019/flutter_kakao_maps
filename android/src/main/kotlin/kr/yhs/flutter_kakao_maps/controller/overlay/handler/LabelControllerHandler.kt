package kr.yhs.flutter_kakao_maps.controller.overlay.handler

import com.kakao.vectormap.LatLng
import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelLayer
import com.kakao.vectormap.label.LabelLayerOptions
import com.kakao.vectormap.label.LabelManager
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelStyles
import com.kakao.vectormap.label.PolylineLabel
import com.kakao.vectormap.label.PolylineLabelOptions
import com.kakao.vectormap.label.PolylineLabelStyles
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.asLatLng
import kr.yhs.flutter_kakao_maps.converter.LabelTypeConverter.asLabelLayerOptions
import kr.yhs.flutter_kakao_maps.converter.LabelTypeConverter.asLabelOptions
import kr.yhs.flutter_kakao_maps.converter.LabelTypeConverter.asLabelStyles
import kr.yhs.flutter_kakao_maps.converter.LabelTypeConverter.asPolylineTextOption
import kr.yhs.flutter_kakao_maps.converter.LabelTypeConverter.asPolylineTextStyles
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asFloat
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asLong
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString

interface LabelControllerHandler {
  val labelManager: LabelManager?

  fun labelHandle(call: MethodCall, result: MethodChannel.Result) {
    val arguments = call.arguments!!.asMap<Any?>()
    if (labelManager == null) {
      throw NullPointerException("LabelManager is null.")
    }

    val layer =
      arguments["layerId"]?.asString()?.let<String, LabelLayer> { labelManager!!.getLayer(it) }
    val poi = layer?.run { arguments["poiId"]?.asString()?.let(layer::getLabel) }
    val polylineText = layer?.run { arguments["labelId"]?.asString()?.let(layer::getPolylineLabel) }

    when (call.method) {
      "createLabelLayer" -> {
        createLabelLayer(arguments.asLabelLayerOptions(), result::success)
      }
      "removeLabelLayer" -> {
        removeLabelLayer(layer!!, result::success)
      }
      "addPoiStyle" -> {
        addPoiStyle(arguments.asLabelStyles()!!, result::success)
      }
      "addPoi" -> {
        val poiOption = arguments["poi"]!!.asLabelOptions(labelManager!!)
        addPoi(layer!!, poiOption, result::success)
      }
      "addPolylineText" -> {
        val labelOption = arguments["label"]!!.asPolylineTextOption()
        addPolylineText(layer!!, labelOption, result::success)
      }
      "removePoi" -> removePoi(layer!!, poi!!, result::success)
      "removePolylineText" -> removePolylineText(layer!!, polylineText!!, result::success)
      // poi Handler
      "changePoiOffsetPosition" -> {
        val x = arguments["x"]?.asFloat()!!
        val y = arguments["y"]?.asFloat()!!
        val forceDpScale = arguments["forceDpScale"]?.asBoolean()
        changePoiOffsetPosition(poi!!, x, y, forceDpScale, result::success)
      }
      "changePoiVisible" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        val autoMove = arguments["autoMove"]?.asBoolean()
        val duration = arguments["millis"]?.asInt()
        changePoiVisible(poi!!, visible, autoMove, duration, result::success)
      }
      "changePoiStyle" -> {
        val styleId = arguments["styleId"]?.asString()!!
        val transition = arguments["transition"]?.asBoolean() ?: false
        changePoiStyle(poi!!, styleId, transition, result::success)
      }
      "changePoiText" -> {
        val text = arguments["text"]?.asString()!!
        val transition = arguments["transition"]?.asBoolean() ?: false
        changePoiText(poi!!, text, transition, result::success)
      }
      "invalidatePoi" -> {
        val styleId = arguments["styleId"]?.asString()!!
        val text = arguments["text"]?.asString()!!
        val transition = arguments["transition"]?.asBoolean() ?: false
        invalidatePoi(poi!!, styleId, text, transition, result::success)
      }
      "movePoi" -> {
        val position = arguments.asLatLng()
        val millis = arguments["millis"]?.asInt()
        movePoi(poi!!, position, millis, result::success)
      }
      "rotatePoi" -> {
        val angle = arguments["angle"]?.asFloat()!!
        val millis = arguments["millis"]?.asInt()
        rotatePoi(poi!!, angle, millis, result::success)
      }
      "scalePoi" -> {
        val x = arguments["x"]?.asFloat()!!
        val y = arguments["y"]?.asFloat()!!
        val millis = arguments["millis"]?.asInt()
        scalePoi(poi!!, x, y, millis, result::success)
      }
      "rankPoi" -> {
        val rank = arguments["rank"]?.asLong()!!
        rankPoi(poi!!, rank, result::success)
      }
      // polyline text handler
      "changePolylineTextStyle" -> {
        val style = arguments["styles"]?.asPolylineTextStyles()
        val text = arguments["text"]?.asString()
        changePolylineTextAndStyle(polylineText!!, style!!, text, result::success)
      }
      "changePolylineTextVisible" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePolylineTextVisible(polylineText!!, visible, result::success)
      }
      // label layer handler
      "changeVisibleAllPoi" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePoiAllVisible(layer!!, visible, result::success)
      }
      "changeVisibleAllPolylineText" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePolylineTextAllVisible(layer!!, visible, result::success)
      }
      "setLayerClickable" -> {
        val clickable = arguments["clickable"]?.asBoolean()!!
        changeLabelLayerClickable(layer!!, clickable, result::success)
      }
      "setLayerZOrder" -> {
        val zOrder = arguments["visible"]?.asInt()!!
        changeLabelLayerZOrder(layer!!, zOrder, result::success)
      }
      else -> result.notImplemented()
    }
  }

  fun createLabelLayer(options: LabelLayerOptions, onSuccess: (Any?) -> Unit)

  fun removeLabelLayer(layer: LabelLayer, onSuccess: (Any?) -> Unit)

  fun addPoiStyle(style: LabelStyles, onSuccess: (Any?) -> Unit)

  fun addPoi(layer: LabelLayer, poi: LabelOptions, onSuccess: (String) -> Unit)

  fun removePoi(layer: LabelLayer, poi: Label, onSuccess: (Any?) -> Unit)

  fun addPolylineText(layer: LabelLayer, label: PolylineLabelOptions, onSuccess: (String) -> Unit)

  fun removePolylineText(layer: LabelLayer, label: PolylineLabel, onSuccess: (Any?) -> Unit)

  // Poi Controller
  fun changePoiOffsetPosition(
    poi: Label,
    x: Float,
    y: Float,
    forceDpScale: Boolean?,
    onSuccess: (Any?) -> Unit,
  )

  fun changePoiVisible(
    poi: Label,
    visible: Boolean,
    autoMove: Boolean?,
    duration: Int?,
    onSuccess: (Any?) -> Unit,
  )

  fun changePoiStyle(poi: Label, styleId: String, transition: Boolean, onSuccess: (Any?) -> Unit)

  fun changePoiText(poi: Label, text: String, transition: Boolean, onSuccess: (Any?) -> Unit)

  fun invalidatePoi(
    poi: Label,
    styleId: String,
    text: String,
    transition: Boolean,
    onSuccess: (Any?) -> Unit,
  )

  fun movePoi(poi: Label, position: LatLng, millis: Int?, onSuccess: (Any?) -> Unit)

  fun rotatePoi(poi: Label, angle: Float, millis: Int?, onSuccess: (Any?) -> Unit)

  fun scalePoi(poi: Label, x: Float, y: Float, millis: Int?, onSuccess: (Any?) -> Unit)

  fun rankPoi(poi: Label, rank: Long, onSuccess: (Any?) -> Unit)

  // Polyline Text Controller
  fun changePolylineTextAndStyle(
    label: PolylineLabel,
    style: PolylineLabelStyles,
    text: String?,
    onSuccess: (Any?) -> Unit,
  )

  fun changePolylineTextVisible(label: PolylineLabel, visible: Boolean, onSuccess: (Any?) -> Unit)

  // Label Controller
  fun changePoiAllVisible(layer: LabelLayer, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun changePolylineTextAllVisible(layer: LabelLayer, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun changeLabelLayerClickable(layer: LabelLayer, clickable: Boolean, onSuccess: (Any?) -> Unit)

  fun changeLabelLayerZOrder(layer: LabelLayer, zOrder: Int, onSuccess: (Any?) -> Unit)
}
