package kr.yhs.flutter_kakao_maps.controller.overlay.handler

import com.kakao.vectormap.shape.DotPoints
import com.kakao.vectormap.shape.MapPoints
import com.kakao.vectormap.shape.Polygon
import com.kakao.vectormap.shape.PolygonOptions
import com.kakao.vectormap.shape.PolygonStylesSet
import com.kakao.vectormap.shape.Polyline
import com.kakao.vectormap.shape.PolylineOptions
import com.kakao.vectormap.shape.PolylineStylesSet
import com.kakao.vectormap.shape.ShapeLayer
import com.kakao.vectormap.shape.ShapeLayerOptions
import com.kakao.vectormap.shape.ShapeManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Arrays
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

interface ShapeControllerHandler {
  val shapeManager: ShapeManager?

  fun shapeHandle(call: MethodCall, result: MethodChannel.Result) {
    val arguments = call.arguments!!.asMap<Any?>()
    if (shapeManager == null) {
      throw NullPointerException("ShapeManager is null.")
    }
    val layer =
      arguments["layerId"]?.asString()?.let<String, ShapeLayer> { shapeManager!!.getLayer(it) }

    val polylineShape = layer?.run { arguments["polylineId"]?.asString()?.let(layer::getPolyline) }
    val polygonShape = layer?.run { arguments["polygonId"]?.asString()?.let(layer::getPolygon) }

    when (call.method) {
      "createShapeLayer" -> createShapeLayer(arguments.asShapeLayerOption(), result::success)
      "removeShapeLayer" -> removeShapeLayer(layer!!, result::success)
      "addPolylineShapeStyle" ->
        addPolylineShapeStyle(arguments.asPolylineStylesSet(), result::success)
      "addPolygonShapeStyle" ->
        addPolygonShapeStyle(arguments.asPolygonStylesSet(), result::success)
      "addPolylineShape" -> {
        val shapeOption = arguments["polyline"]!!.asPolylineOption(shapeManager!!)
        addPolylineShape(layer!!, shapeOption, result::success)
      }
      "addPolygonShape" -> {
        val shapeOption = arguments["polygon"]!!.asPolygonOption(shapeManager!!)
        addPolygonShape(layer!!, shapeOption, result::success)
      }
      "removePolylineShape" -> removePolylineShape(layer!!, polylineShape!!, result::success)
      "removePolygonShape" -> removePolygonShape(layer!!, polygonShape!!, result::success)
      "changePolylineVisible" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePolylineVisible(polylineShape!!, visible, result::success)
      }
      "changePolygonVisible" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePolygonVisible(polygonShape!!, visible, result::success)
      }
      "changePolyline" -> {
        val styleId: String? = arguments["styleId"]?.asString()
        val position = arguments["position"]!!.asMap<Any?>()
        if (position["type"]!!.asInt() == 0) {
          val mapPosition = position.asMapPoints().let { Arrays.asList(it) }
          changePolylineFromMapPoints(polylineShape!!, styleId!!, mapPosition, result::success)
        } else {
          val dotPosition: List<DotPoints> = position.asDotPoints().let { Arrays.asList(it) }
          changePolylineFromDotPoints(polylineShape!!, styleId!!, dotPosition, result::success)
        }
      }
      "changePolygon" -> {
        val styleId = arguments["styleId"]?.asString()
        val position = arguments["position"]!!.asMap<Any?>()
        if (position["type"]!!.asInt() == 0) {
          val mapPosition = position.asMapPoints().let { Arrays.asList(it) }
          changePolygonFromMapPoints(polygonShape!!, styleId!!, mapPosition, result::success)
        } else {
          val dotPosition: List<DotPoints> = position.asDotPoints().let { Arrays.asList(it) }
          changePolygonFromDotPoints(polygonShape!!, styleId!!, dotPosition, result::success)
        }
      }
      "changeVisibleAllPolyline" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePolylineAllVisible(layer!!, visible, result::success)
      }
      "changeVisibleAllPolygon" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changePolygonAllVisible(layer!!, visible, result::success)
      }
      else -> result.notImplemented()
    }
  }

  fun createShapeLayer(options: ShapeLayerOptions, onSuccess: (Any?) -> Unit)

  fun removeShapeLayer(layer: ShapeLayer, onSuccess: (Any?) -> Unit)

  fun addPolylineShapeStyle(style: PolylineStylesSet, onSuccess: (String) -> Unit)

  fun addPolygonShapeStyle(style: PolygonStylesSet, onSuccess: (String) -> Unit)

  fun addPolylineShape(layer: ShapeLayer, shape: PolylineOptions, onSuccess: (String) -> Unit)

  fun addPolygonShape(layer: ShapeLayer, shape: PolygonOptions, onSuccess: (String) -> Unit)

  fun removePolylineShape(layer: ShapeLayer, shape: Polyline, onSuccess: (Any?) -> Unit)

  fun removePolygonShape(layer: ShapeLayer, shape: Polygon, onSuccess: (Any?) -> Unit)

  fun changePolylineVisible(shape: Polyline, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun changePolygonVisible(shape: Polygon, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun changePolylineFromMapPoints(
    shape: Polyline,
    styleId: String,
    position: List<MapPoints>,
    onSuccess: (Any?) -> Unit,
  )

  fun changePolygonFromMapPoints(
    shape: Polygon,
    styleId: String,
    position: List<MapPoints>,
    onSuccess: (Any?) -> Unit,
  )

  fun changePolylineFromDotPoints(
    shape: Polyline,
    styleId: String,
    position: List<DotPoints>,
    onSuccess: (Any?) -> Unit,
  )

  fun changePolygonFromDotPoints(
    shape: Polygon,
    styleId: String,
    position: List<DotPoints>,
    onSuccess: (Any?) -> Unit,
  )

  fun changePolylineAllVisible(layer: ShapeLayer, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun changePolygonAllVisible(layer: ShapeLayer, visible: Boolean, onSuccess: (Any?) -> Unit)
}
