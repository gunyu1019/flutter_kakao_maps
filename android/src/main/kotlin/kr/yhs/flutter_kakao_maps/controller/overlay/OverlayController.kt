package kr.yhs.flutter_kakao_maps.controller.overlay

import com.kakao.vectormap.CurveType
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.label.Badge
import com.kakao.vectormap.label.BadgeOptions
import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelLayer
import com.kakao.vectormap.label.LabelLayerOptions
import com.kakao.vectormap.label.LabelManager
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelStyles
import com.kakao.vectormap.label.LodLabel
import com.kakao.vectormap.label.LodLabelLayer
import com.kakao.vectormap.label.PathOptions
import com.kakao.vectormap.label.PolylineLabel
import com.kakao.vectormap.label.PolylineLabelOptions
import com.kakao.vectormap.label.PolylineLabelStyles
import com.kakao.vectormap.label.TrackingManager
import com.kakao.vectormap.route.RouteLine
import com.kakao.vectormap.route.RouteLineLayer
import com.kakao.vectormap.route.RouteLineManager
import com.kakao.vectormap.route.RouteLineOptions
import com.kakao.vectormap.route.RouteLineSegment
import com.kakao.vectormap.route.RouteLineStylesSet
import com.kakao.vectormap.shape.DimScreenCover
import com.kakao.vectormap.shape.DimScreenManager
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
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.DimScreenControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.LabelControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.LodLabelControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.RouteControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.ShapeControllerHandler
import kr.yhs.flutter_kakao_maps.controller.overlay.handler.TrackingControllerHandler
import kr.yhs.flutter_kakao_maps.converter.LabelTypeConverter.asLabelTextBuilder
import kr.yhs.flutter_kakao_maps.converter.PrimitiveTypeConverter.asMap
import kr.yhs.flutter_kakao_maps.model.OverlayType

class OverlayController(private val channel: MethodChannel, private val kakaoMap: KakaoMap) :
  LabelControllerHandler,
  LodLabelControllerHandler,
  ShapeControllerHandler,
  RouteControllerHandler,
  DimScreenControllerHandler,
  TrackingControllerHandler {
  override val trackingManager: TrackingManager?
    get() = kakaoMap.trackingManager

  override val dimScreenManager: DimScreenManager?
    get() = kakaoMap.dimScreenManager

  override val labelManager: LabelManager?
    get() = kakaoMap.labelManager

  override val shapeManager: ShapeManager?
    get() = kakaoMap.shapeManager

  override val routeManager: RouteLineManager?
    get() = kakaoMap.routeLineManager

  // TEMPORARY
  var poiBadges: MutableMap<String, MutableMap<String, MutableMap<String, Badge>>> = mutableMapOf()
  var lodPoiBadges: MutableMap<String, MutableMap<String, MutableMap<String, Badge>>> =
    mutableMapOf()

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
      OverlayType.DimScreen -> dimScreenHandle(call, result)
      OverlayType.Tracking -> trackingHandle(call, result)
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

  override fun addPoi(layer: LabelLayer, poi: LabelOptions, onSuccess: (String?) -> Unit) {
    layer.addLabel(poi).let { onSuccess.invoke(it?.labelId) }
  }

  override fun removePoi(layer: LabelLayer, poi: Label, onSuccess: Function1<Any?, Unit>) {
    layer.remove(poi)
    onSuccess.invoke(null)
  }

  override fun addPolylineText(
    layer: LabelLayer,
    label: PolylineLabelOptions,
    onSuccess: (String?) -> Unit,
  ) {
    layer.addPolylineLabel(label).let { onSuccess.invoke(it?.labelId) }
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

  override fun addLodPoi(layer: LodLabelLayer, poi: LabelOptions, onSuccess: (String?) -> Unit) {
    val label = layer.addLodLabel(poi).let { onSuccess.invoke(it?.labelId) }
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

  override fun addPolylineShapeStyle(style: PolylineStylesSet, onSuccess: (String?) -> Unit) {
    shapeManager!!.addPolylineStyles(style).let { onSuccess.invoke(it?.styleId) }
  }

  override fun addPolygonShapeStyle(style: PolygonStylesSet, onSuccess: (String?) -> Unit) {
    shapeManager!!.addPolygonStyles(style).let {
      val dimScreenStyleSet = PolygonStylesSet.from(it.styleId, it.styles)
      dimScreenManager?.addPolygonStyles(dimScreenStyleSet)
      onSuccess.invoke(it?.styleId)
    }
  }

  override fun addPolylineShape(
    layer: ShapeLayer,
    shape: PolylineOptions,
    onSuccess: (String?) -> Unit,
  ) {
    layer.addPolyline(shape).let { onSuccess.invoke(it?.id) }
  }

  override fun addPolygonShape(
    layer: ShapeLayer,
    shape: PolygonOptions,
    onSuccess: (String?) -> Unit,
  ) {
    layer.addPolygon(shape).let { onSuccess.invoke(it?.id) }
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

  override fun addRouteStyle(style: RouteLineStylesSet, onSuccess: (String?) -> Unit) {
    routeManager!!.addStylesSet(style).let { onSuccess.invoke(it?.styleId) }
  }

  override fun addRoute(
    layer: RouteLineLayer,
    route: RouteLineOptions,
    onSuccess: (String?) -> Unit,
  ) {
    layer.addRouteLine(route).let { onSuccess.invoke(it?.lineId) }
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

  override fun setTrackingRotation(rotation: Boolean, onSuccess: (Any?) -> Unit) {
    trackingManager?.setTrackingRotation(rotation)
  }

  override fun startTracking(label: Label, onSuccess: (Any?) -> Unit) {
    trackingManager?.startTracking(label)
  }

  override fun stopTracking(onSuccess: (Any?) -> Unit) {
    trackingManager?.stopTracking()
  }

  override fun setDimColor(color: Int, onSuccess: (Any?) -> Unit) {
    dimScreenLayer?.setColor(color)
    onSuccess.invoke(null)
  }

  override fun setDimVisible(visible: Boolean, onSuccess: (Any?) -> Unit) {
    dimScreenLayer?.setVisible(visible)
    onSuccess.invoke(null)
  }

  override fun setDimCorver(cover: DimScreenCover, onSuccess: (Any?) -> Unit) {
    dimScreenLayer?.setDimScreenCover(cover)
    onSuccess.invoke(null)
  }

  override fun addDimHighlightPolygonShape(shape: PolygonOptions, onSuccess: (String?) -> Unit) {
    dimScreenLayer?.addPolygon(shape).let { onSuccess.invoke(it?.id) }
  }

  override fun removeDimHighlightPolygonShape(polygonId: String, onSuccess: (Any?) -> Unit) {
    val polygon = dimScreenLayer?.getPolygon(polygonId)
    dimScreenLayer?.remove(polygon)
    onSuccess.invoke(null)
  }

  override fun addPoiBadge(
    poi: Label,
    badgeOption: BadgeOptions,
    visible: Boolean,
    onSuccess: (String?) -> Unit,
  ) {
    if (!poiBadges.containsKey(poi.layerId)) poiBadges[poi.layerId] = mutableMapOf()
    if (!poiBadges[poi.layerId]!!.containsKey(poi.labelId))
      poiBadges[poi.layerId]!![poi.labelId] = mutableMapOf()

    val badge = (poi.addBadge(badgeOption))?.firstOrNull()
    badge?.let { poiBadges[poi.layerId]!![poi.labelId]!![badgeOption.id] = it }
    if (visible) {
      badge?.show()
    } else {
      badge?.hide()
    }
    onSuccess.invoke(badge?.id)
  }

  override fun removePoiBadge(poi: Label, badgeId: String, onSuccess: (Any?) -> Unit) {
    poiBadges[poi.layerId]?.get(poi.labelId)?.remove(badgeId)!!.let(poi::removeBadge)
    onSuccess.invoke(null)
  }

  override fun addPoiBadge(
    poi: LodLabel,
    badgeOption: BadgeOptions,
    visible: Boolean,
    onSuccess: (String?) -> Unit,
  ) {
    if (!poiBadges.containsKey(poi.layerId)) poiBadges[poi.layerId] = mutableMapOf()
    if (!poiBadges[poi.layerId]!!.containsKey(poi.labelId))
      poiBadges[poi.layerId]!![poi.labelId] = mutableMapOf()

    val badge = (poi.addBadge(badgeOption))?.firstOrNull()
    badge?.let { poiBadges[poi.layerId]!![poi.labelId]!![badgeOption.id] = it }
    if (visible) {
      badge?.show()
    } else {
      badge?.hide()
    }
    onSuccess.invoke(badge?.id)
  }

  override fun removePoiBadge(poi: LodLabel, badgeId: String, onSuccess: (Any?) -> Unit) {
    lodPoiBadges[poi.layerId]?.get(poi.labelId)?.remove(badgeId)!!.let(poi::removeBadge)
    onSuccess.invoke(null)
  }

  override fun changePoiBadgeVisible(
    poi: Label,
    badgeId: String,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    val badge = poiBadges[poi.layerId]?.get(poi.labelId)?.get(badgeId)
    if (visible) {
      badge?.show()
    } else {
      badge?.hide()
    }
    onSuccess.invoke(null)
  }

  override fun changePoiBadgeVisible(
    poi: LodLabel,
    badgeId: String,
    visible: Boolean,
    onSuccess: (Any?) -> Unit,
  ) {
    val badge = lodPoiBadges[poi.layerId]?.get(poi.labelId)?.get(badgeId)
    if (visible) {
      badge?.show()
    } else {
      badge?.hide()
    }
    onSuccess.invoke(null)
  }

  override fun addShareTransformPoi(poi: Label, targetPoi: Label, onSuccess: (Any?) -> Unit) {
    poi.addShareTransform(targetPoi)
    onSuccess.invoke(null)
  }

  override fun addShareTransformPoi(
    poi: Label,
    targetShapeLayerId: String,
    targetShapeId: String,
    onSuccess: (Any?) -> Unit,
  ) {
    shapeManager
      ?.getLayer(targetShapeLayerId)
      ?.getPolygon(targetShapeId)!!
      .let(poi::addShareTransform)
    onSuccess.invoke(null)
  }

  override fun removeShareTransformPoi(poi: Label, targetPoi: Label, onSuccess: (Any?) -> Unit) {
    poi.removeSharePosition(targetPoi)
    onSuccess.invoke(null)
  }

  override fun removeShareTransformPoi(
    poi: Label,
    targetShapeLayerId: String,
    targetShapeId: String,
    onSuccess: (Any?) -> Unit,
  ) {
    shapeManager
      ?.getLayer(targetShapeLayerId)
      ?.getPolygon(targetShapeId)!!
      .let(poi::removeShareTransform)
    onSuccess.invoke(null)
  }

  override fun addSharePositionPoi(poi: Label, targetPoi: Label, onSuccess: (Any?) -> Unit) {
    poi.addShareTransform(targetPoi)
    onSuccess.invoke(null)
  }

  override fun removeSharePositionPoi(poi: Label, targetPoi: Label, onSuccess: (Any?) -> Unit) {
    poi.removeShareTransform(targetPoi)
    onSuccess.invoke(null)
  }

  override fun movePathPoi(poi: Label, path: PathOptions, onSuccess: (Any?) -> Unit) {
    poi.moveOnPath(path)
    onSuccess.invoke(null)
  }
}
