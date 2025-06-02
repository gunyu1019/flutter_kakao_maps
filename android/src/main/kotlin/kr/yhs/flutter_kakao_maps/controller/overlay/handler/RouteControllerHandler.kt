package kr.yhs.flutter_kakao_maps.controller.overlay.handler

import com.kakao.vectormap.CurveType
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.route.RouteLine
import com.kakao.vectormap.route.RouteLineLayer
import com.kakao.vectormap.route.RouteLineManager
import com.kakao.vectormap.route.RouteLineOptions
import com.kakao.vectormap.route.RouteLineStylesSet
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kr.yhs.flutter_kakao_maps.converter.CameraTypeConverter.asLatLng
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asBoolean
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asInt
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asList
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asString
import kr.yhs.flutter_kakao_maps.converter.RouteTypeConverter.asRouteMultipleOption
import kr.yhs.flutter_kakao_maps.converter.RouteTypeConverter.asRouteOption
import kr.yhs.flutter_kakao_maps.converter.RouteTypeConverter.asRouteStylesSet

interface RouteControllerHandler {
  val routeManager: RouteLineManager?

  fun routeHandle(call: MethodCall, result: MethodChannel.Result) {
    val arguments = call.arguments!!.asMap<Any?>()
    if (routeManager == null) {
      throw NullPointerException("RouteManager is null.")
    }
    val layer =
      arguments["layerId"]?.asString()?.let<String, RouteLineLayer> { routeManager!!.getLayer(it) }

    val routeLine = layer?.run { arguments["routeId"]?.asString()?.let(layer::getRouteLine) }

    when (call.method) {
      "createRouteLayer" -> {
        val zOrder = arguments["zOrder"]?.asInt()
        val layerId = arguments["layerId"]!!.asString()
        createRouteLayer(layerId, zOrder, result::success)
      }
      "removeRouteLayer" -> removeRouteLayer(layer!!, result::success)
      "addRouteStyle" -> addRouteStyle(arguments.asRouteStylesSet(), result::success)
      "addRoute" ->
        addRoute(layer!!, arguments["route"]!!.asRouteOption(routeManager!!), result::success)
      "addMultipleRoute" ->
        addRoute(
          layer!!,
          arguments["route"]!!.asRouteMultipleOption(routeManager!!),
          result::success,
        )
      "removeRoute" -> removeRoute(layer!!, routeLine!!, result::success)
      "changeRoute" -> {
        val styleId = arguments["styleId"]!!.asString()
        val curveType =
          arguments["curveType"]!!.asList<Any>().map { it.asInt().let { CurveType.getEnum(it) } }
        val points =
          arguments["points"]!!.asList<Any>().map<Any, List<LatLng>> {
            it.asList<Any>().map { it.asLatLng() }
          }
        changeRoute(routeLine!!, styleId, curveType, points, result::success)
      }
      "changeRouteVisible" ->
        changeRouteVisible(routeLine!!, arguments["visible"]!!.asBoolean(), result::success)
      "changeRouteZOrder" ->
        changeRouteZOrder(routeLine!!, arguments["zOrder"]!!.asInt(), result::success)
      "changeVisibleAllRoute" -> {
        val visible = arguments["visible"]?.asBoolean()!!
        changeRouteLayerVisible(layer!!, visible, result::success)
      }
      else -> result.notImplemented()
    }
  }

  fun createRouteLayer(layerId: String, zOrder: Int?, onSuccess: (Any?) -> Unit)

  fun removeRouteLayer(layer: RouteLineLayer, onSuccess: (Any?) -> Unit)

  fun addRouteStyle(style: RouteLineStylesSet, onSuccess: (String) -> Unit)

  fun addRoute(layer: RouteLineLayer, route: RouteLineOptions, onSuccess: (String) -> Unit)

  fun removeRoute(layer: RouteLineLayer, route: RouteLine, onSuccess: (Any?) -> Unit)

  fun changeRoute(
    route: RouteLine,
    styleId: String,
    curveType: List<CurveType>,
    points: List<List<LatLng>>,
    onSuccess: (Any?) -> Unit,
  )

  fun changeRouteVisible(route: RouteLine, visible: Boolean, onSuccess: (Any?) -> Unit)

  fun changeRouteZOrder(route: RouteLine, zOrder: Int, onSuccess: (Any?) -> Unit)

  fun changeRouteLayerVisible(layer: RouteLineLayer, visible: Boolean, onSuccess: (Any?) -> Unit)
}
