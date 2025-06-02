package kr.yhs.flutter_kakao_maps.controller.overlay

import com.kakao.vectormap.CurveType
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelLayer
import com.kakao.vectormap.label.LabelLayerOptions
import com.kakao.vectormap.label.LabelManager
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelStyles
import com.kakao.vectormap.label.LodLabel
import com.kakao.vectormap.label.LodLabelLayer
import com.kakao.vectormap.label.PolylineLabel
import com.kakao.vectormap.label.PolylineLabelOptions
import com.kakao.vectormap.label.PolylineLabelStyles
import com.kakao.vectormap.route.RouteLine
import com.kakao.vectormap.route.RouteLineLayer
import com.kakao.vectormap.route.RouteLineManager
import com.kakao.vectormap.route.RouteLineOptions
import com.kakao.vectormap.route.RouteLineSegment
import com.kakao.vectormap.route.RouteLineStylesSet
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
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.LabelControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.LodLabelControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.RouteControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.ShapeControllerHandler
import kr.yhs.flutter_kakao_maps.converter.LabelTypeConverter.asLabelTextBuilder
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.model.OverlayType

class OverlayController(private val channel: MethodChannel, private val kakaoMap: KakaoMap) :
  LabelControllerHandler,
  LodLabelControllerHandler,
  ShapeControllerHandler,
  RouteControllerHandler {
  override val labelManager: LabelManager?
    get() = kakaoMap.getLabelManager()

  override val shapeManager: ShapeManager?
    get() = kakaoMap.getShapeManager()

  override val routeManager: RouteLineManager?
    get() = kakaoMap.getRouteLineManager()

  init {
    channel.setMethodCallHandler(::handle)
  }

  fun handle(call: MethodCall, result: MethodChannel.Result) =
    when (
      OverlayType.values().filter { call.arguments.asMap<Int>()["type"]!! == it.value }.first()
    ) {
      OverlayType.Label -> labelHandle(call, result)
      OverlayType.LodLabel -> lodLabelHandle(call, result)
      OverlayType.Shape -> shapeHandle(call, result)
      OverlayType.Route -> routeHandle(call, result)
    }

  override fun createLabelLayer(options: LabelLayerOptions, onSuccess: (Any?) -> Unit) {
    labelManager!!.addLayer(options)
    onSuccess.invoke(null)
  }

  override fun removeLabelLayer(layer: LabelLayer, onSuccess: (Any?) -> Unit) {
    labelManager!!.remove(layer)
    onSuccess.invoke(null)
  }

  override fun addPoiStyle(style: LabelStyles, onSuccess: (Any?) -> Unit) {
    labelManager!!.addLabelStyles(style).let { it -> onSuccess.invoke(it?.styleId) }
  }

  override fun addPoi(layer: LabelLayer, poi: LabelOptions, onSuccess: (String) -> Unit) {
    val label = layer.addLabel(poi)
    onSuccess.invoke(label.labelId)
  }

  override fun removePoi(layer: LabelLayer, poi: Label, onSuccess: Function1<Any?, Unit>) {
    layer.remove(poi)
    onSuccess.invoke(null)
  }

  override fun addPolylineText(
    layer: LabelLayer,
    label: PolylineLabelOptions,
    onSuccess: (String) -> Unit,
  ) {
    val polylineText = layer.addPolylineLabel(label)
    onSuccess.invoke(polylineText.labelId)
  }

  override fun removePolylineText(
    layer: LabelLayer,
    label: PolylineLabel,
    onSuccess: (Any?) -> Unit,
  ) {
    layer.remove(label)
    onSuccess.invoke(null)
  }

  override fun changePoiOffsetPosition(
    poi: Label,
    x: Float,
    y: Float,
    forceDpScale: Boolean?,
    onSuccess: Function1<Any?, Unit>,
  ) {
    forceDpScale?.let { poi.changePixelOffset(x, y, it) } ?: poi.changePixelOffset(x, y)
    onSuccess.invoke(null)
  }

  override fun changePoiVisible(
    poi: Label,
    visible: Boolean,
    autoMove: Boolean?,
    duration: Int?,
    onSuccess: Function1<Any?, Unit>,
  ) {
    if (visible) {
      poi.show(autoMove ?: false, duration ?: 300)
    } else {
      poi.hide()
    }
    onSuccess.invoke(null)
  }

  override fun changePoiStyle(
    poi: Label,
    styleId: String,
    transition: Boolean,
    onSuccess: Function1<Any?, Unit>,
  ) {
    val poiStyle = labelManager!!.getLabelStyles(styleId)
    poi.changeStyles(poiStyle, transition)
    onSuccess.invoke(null)
  }

  override fun changePoiText(
    poi: Label,
    text: String,
    transition: Boolean,
    onSuccess: Function1<Any?, Unit>,
  ) {
    poi.changeText(text.asLabelTextBuilder(), transition)
    onSuccess.invoke(null)
  }

  override fun invalidatePoi(
    poi: Label,
    styleId: String,
    text: String,
    transition: Boolean,
    onSuccess: Function1<Any?, Unit>,
  ) {
    val poiStyle = labelManager!!.getLabelStyles(styleId)
    poi.setStyles(poiStyle)
    poi.setTexts(text.asLabelTextBuilder())
    poi.invalidate(transition)
    onSuccess.invoke(null)
  }

  override fun movePoi(
    poi: Label,
    position: LatLng,
    millis: Int?,
    onSuccess: Function1<Any?, Unit>,
  ) {
    millis?.let { poi.moveTo(position, it) } ?: poi.moveTo(position)
    onSuccess.invoke(null)
  }

  override fun rotatePoi(poi: Label, angle: Float, millis: Int?, onSuccess: Function1<Any?, Unit>) {
    millis?.let { poi.rotateTo(angle, it) } ?: poi.rotateTo(angle)
    onSuccess.invoke(null)
  }

  override fun scalePoi(
    poi: Label,
    x: Float,
    y: Float,
    millis: Int?,
    onSuccess: Function1<Any?, Unit>,
  ) {
    millis?.let { poi.scaleTo(x, y, it) } ?: poi.scaleTo(x, y)
    onSuccess.invoke(null)
  }

  override fun rankPoi(poi: Label, rank: Long, onSuccess: Function1<Any?, Unit>) {
    poi.changeRank(rank)
    onSuccess.invoke(null)
  }

  override fun changePolylineTextAndStyle(
    label: PolylineLabel,
    style: PolylineLabelStyles,
    text: String?,
    onSuccess: (Any?) -> Unit,
  ) {
    text?.let { label.changeTextAndStyles(it, style) } ?: label.changeStyles(style)
    onSuccess.invoke(null)
  }

  override fun changePolylineTextVisible(
    label: PolylineLabel,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    if (visible) {
      label.show()
    } else {
      label.hide()
    }
    onSuccess.invoke(null)
  }

  override fun createLodLabelLayer(options: LabelLayerOptions, onSuccess: (Any?) -> Unit) {
    labelManager!!.addLodLayer(options)
    onSuccess.invoke(null)
  }

  override fun removeLodLabelLayer(layer: LodLabelLayer, onSuccess: (Any?) -> Unit) {
    labelManager!!.remove(layer)
    onSuccess.invoke(null)
  }

  override fun addLodPoi(layer: LodLabelLayer, poi: LabelOptions, onSuccess: (String) -> Unit) {
    val label = layer.addLodLabel(poi)
    onSuccess.invoke(label.labelId)
  }

  override fun removeLodPoi(layer: LodLabelLayer, poi: LodLabel, onSuccess: (Any?) -> Unit) {
    layer.remove(poi)
    onSuccess.invoke(null)
  }

  override fun changeLodPoiVisible(poi: LodLabel, visible: Boolean, onSuccess: (Any?) -> Unit) {
    if (visible) {
      poi.show()
    } else {
      poi.hide()
    }
    onSuccess.invoke(null)
  }

  override fun changeLodPoiStyle(
    poi: LodLabel,
    styleId: String,
    transition: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    val poiStyle = labelManager!!.getLabelStyles(styleId)
    poi.changeStyles(poiStyle, transition)
    onSuccess.invoke(null)
  }

  override fun changeLodPoiText(
    poi: LodLabel,
    text: String,
    transition: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    poi.changeText(text.asLabelTextBuilder(), transition)
    onSuccess.invoke(null)
  }

  override fun rankLodPoi(poi: LodLabel, rank: Long, onSuccess: (Any?) -> Unit) {
    poi.changeRank(rank)
    onSuccess.invoke(null)
  }

  override fun createShapeLayer(options: ShapeLayerOptions, onSuccess: (Any?) -> Unit) {
    shapeManager!!.addLayer(options)
    onSuccess.invoke(null)
  }

  override fun removeShapeLayer(layer: ShapeLayer, onSuccess: (Any?) -> Unit) {
    shapeManager!!.remove(layer)
    onSuccess.invoke(null)
  }

  override fun addPolylineShapeStyle(style: PolylineStylesSet, onSuccess: (String) -> Unit) {
    val styleSet = shapeManager!!.addPolylineStyles(style)
    onSuccess.invoke(styleSet.styleId)
  }

  override fun addPolygonShapeStyle(style: PolygonStylesSet, onSuccess: (String) -> Unit) {
    val styleSet = shapeManager!!.addPolygonStyles(style)
    onSuccess.invoke(styleSet.styleId)
  }

  override fun addPolylineShape(
    layer: ShapeLayer,
    shape: PolylineOptions,
    onSuccess: (String) -> Unit,
  ) {
    val polylineShape = layer.addPolyline(shape)
    onSuccess.invoke(polylineShape.id)
  }

  override fun addPolygonShape(
    layer: ShapeLayer,
    shape: PolygonOptions,
    onSuccess: (String) -> Unit,
  ) {
    val polylineShape = layer.addPolygon(shape)
    onSuccess.invoke(polylineShape.id)
  }

  override fun removePolylineShape(layer: ShapeLayer, shape: Polyline, onSuccess: (Any?) -> Unit) {
    layer.remove(shape)
    onSuccess.invoke(null)
  }

  override fun removePolygonShape(layer: ShapeLayer, shape: Polygon, onSuccess: (Any?) -> Unit) {
    layer.remove(shape)
    onSuccess.invoke(null)
  }

  override fun changePolylineVisible(shape: Polyline, visible: Boolean, onSuccess: (Any?) -> Unit) {
    if (visible) {
      shape.show()
    } else {
      shape.hide()
    }
    onSuccess.invoke(null)
  }

  override fun changePolygonVisible(shape: Polygon, visible: Boolean, onSuccess: (Any?) -> Unit) {
    if (visible) {
      shape.show()
    } else {
      shape.hide()
    }
    onSuccess.invoke(null)
  }

  override fun changePolylineFromMapPoints(
    shape: Polyline,
    styleId: String,
    position: List<MapPoints>,
    onSuccess: (Any?) -> Unit,
  ) {
    val style = shapeManager!!.getPolylineStyles(styleId)
    shape.changeStylesAndMapPoints(style, position)
    onSuccess.invoke(null)
  }

  override fun changePolygonFromMapPoints(
    shape: Polygon,
    styleId: String,
    position: List<MapPoints>,
    onSuccess: (Any?) -> Unit,
  ) {
    val style = shapeManager!!.getPolygonStyles(styleId)
    shape.changeStylesAndMapPoints(style, position)
    onSuccess.invoke(null)
  }

  override fun changePolylineFromDotPoints(
    shape: Polyline,
    styleId: String,
    position: List<DotPoints>,
    onSuccess: (Any?) -> Unit,
  ) {
    val style = shapeManager!!.getPolylineStyles(styleId)
    shape.changeStylesAndDotPoints(style, position)
    onSuccess.invoke(null)
  }

  override fun changePolygonFromDotPoints(
    shape: Polygon,
    styleId: String,
    position: List<DotPoints>,
    onSuccess: (Any?) -> Unit,
  ) {
    val style = shapeManager!!.getPolygonStyles(styleId)
    shape.changeStylesAndDotPoints(style, position)
    onSuccess.invoke(null)
  }

  override fun createRouteLayer(layerId: String, zOrder: Int?, onSuccess: (Any?) -> Unit) {
    (zOrder?.let { routeManager!!.addLayer(layerId, it) }) ?: routeManager!!.addLayer(layerId)
    onSuccess.invoke(null)
  }

  override fun removeRouteLayer(layer: RouteLineLayer, onSuccess: (Any?) -> Unit) {
    routeManager!!.remove(layer)
    onSuccess.invoke(null)
  }

  override fun addRouteStyle(style: RouteLineStylesSet, onSuccess: (String) -> Unit) {
    routeManager!!.addStylesSet(style).let { it.styleId }.let(onSuccess::invoke)
  }

  override fun addRoute(
    layer: RouteLineLayer,
    route: RouteLineOptions,
    onSuccess: (String) -> Unit,
  ) {
    layer.addRouteLine(route).let { it.lineId }.let(onSuccess::invoke)
  }

  override fun removeRoute(layer: RouteLineLayer, route: RouteLine, onSuccess: (Any?) -> Unit) {
    layer.remove(route)
    onSuccess.invoke(null)
  }

  override fun changeRoute(
    route: RouteLine,
    styleId: String,
    curveType: List<CurveType>,
    points: List<List<LatLng>>,
    onSuccess: (Any?) -> Unit,
  ) {
    points
      .mapIndexed { index, element ->
        RouteLineSegment.from(element).apply { curveType[index].let(::setCurveType) }
      }
      .let(route::changeSegments)
    routeManager!!.addStylesSet(RouteLineStylesSet.from(styleId, listOf())).let(route::changeStyle)
    onSuccess.invoke(null)
  }

  override fun changeRouteVisible(route: RouteLine, visible: Boolean, onSuccess: (Any?) -> Unit) {
    if (visible) {
      route.show()
    } else {
      route.hide()
    }
    onSuccess.invoke(null)
  }

  override fun changeRouteZOrder(route: RouteLine, zOrder: Int, onSuccess: (Any?) -> Unit) {
    route.setZOrder(zOrder)
    onSuccess.invoke(null)
  }

  override fun changePoiAllVisible(layer: LabelLayer, visible: Boolean, onSuccess: (Any?) -> Unit) {
    if (visible) {
      layer.showAllLabels()
    } else {
      layer.hideAllLabels()
    }
    onSuccess.invoke(null)
  }

  override fun changePolylineTextAllVisible(
    layer: LabelLayer,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    if (visible) {
      layer.showAllPolylineLabels()
    } else {
      layer.hideAllPolylineLabels()
    }
    onSuccess.invoke(null)
  }

  override fun changeLabelLayerClickable(
    layer: LabelLayer,
    clickable: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    layer.setClickable(clickable)
  }

  override fun changeLabelLayerZOrder(layer: LabelLayer, zOrder: Int, onSuccess: (Any?) -> Unit) {
    layer.setZOrder(zOrder)
  }

  override fun changeLodPoiAllVisible(
    layer: LodLabelLayer,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    if (visible) {
      layer.showAllLodLabels()
    } else {
      layer.hideAllLodLabels()
    }
    onSuccess.invoke(null)
  }

  override fun changeLabelLayerClickable(
    layer: LodLabelLayer,
    clickable: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    layer.setClickable(clickable)
    onSuccess.invoke(null)
  }

  override fun changeLabelLayerZOrder(
    layer: LodLabelLayer,
    zOrder: Int,
    onSuccess: (Any?) -> Unit,
  ) {
    layer.setZOrder(zOrder)
    onSuccess.invoke(null)
  }

  override fun changePolylineAllVisible(
    layer: ShapeLayer,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    /* if (visible) {
        layer.showAllPolyline()
    } else {
        layer.hideAllPolyline()
    } */
    layer.getAllPolylines().map { shape ->
      if (visible) {
        shape.show()
      } else {
        shape.hide()
      }
    }
    onSuccess.invoke(null)
  }

  override fun changePolygonAllVisible(
    layer: ShapeLayer,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    if (visible) {
      layer.showAllPolygon()
    } else {
      layer.hideAllPolygon()
    }
    onSuccess.invoke(null)
  }

  override fun changeRouteLayerVisible(
    layer: RouteLineLayer,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    layer.setVisible(visible)
    onSuccess.invoke(null)
  }
}
