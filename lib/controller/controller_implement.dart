part of '../kakao_map_sdk.dart';

class KakaoMapControllerImplement extends KakaoMapController {
  final MethodChannel channel;

  @override
  final MethodChannel overlayChannel;

  KakaoMapControllerImplement(this.channel, {required this.overlayChannel}) {
    _initalizeOverlayController();
  }

  /* Sender */
  @override
  Future<CameraPosition> getCameraPosition() async {
    final rawCameraPosition = await channel.invokeMethod("getCameraPosition");
    return CameraPosition.fromMessageable(rawCameraPosition);
  }

  @override
  Future<void> moveCamera(CameraUpdate camera,
      {CameraAnimation? animation}) async {
    await channel.invokeMethod("moveCamera", {
      "cameraUpdate": camera.toMessageable(),
      "cameraAnimation": animation?.toMessageable()
    });
  }

  @override
  Future<LatLng?> fromScreenPoint(int x, int y) async {
    final position =
        await channel.invokeMethod("fromScreenPoint", {"x": x, "y": y});
    if (position == null) {
      return null;
    }
    return LatLng.fromMessageable(position);
  }

  @override
  Future<KPoint?> toScreenPoint(LatLng position) async {
    final point =
        await channel.invokeMethod("toScreenPoint", position.toMessageable());
    if (point == null) {
      return null;
    }
    return KPoint(point['x'], point['y']);
  }

  @override
  Future<void> setGesture(GestureType gesture, bool enable) async {
    await channel.invokeMethod(
        "setGestureEnable", {"gestureType": gesture.value, "enable": enable});
  }

  @override
  Future<void> clearCache() async {
    await channel.invokeMethod("clearCache");
  }

  @override
  Future<void> clearDiskCache() async {
    await channel.invokeMethod("clearDiskCache");
  }

  @override
  Future<bool> canShowPosition(int zoomLevel, List<LatLng> position) async {
    final result = await channel.invokeMethod("canShowPosition", {
      "zoomLevel": zoomLevel,
      "position": position.map((e) => e.toMessageable()).toList()
    });
    return result;
  }

  @override
  Future<void> changeMapType(MapType mapType) async {
    await channel.invokeMethod("changeMapType", {"mapType": mapType.value});
  }

  @override
  Future<void> showOverlay(MapOverlay overlay) async {
    await channel.invokeMethod(
        "overlayVisible", {"overlayType": overlay.value, "visible": true});
  }

  @override
  Future<void> hideOverlay(MapOverlay overlay) async {
    await channel.invokeMethod(
        "overlayVisible", {"overlayType": overlay.value, "visible": false});
  }

  @override
  Future<double> fetchBuildingHeightScale() async {
    final result = await channel.invokeMethod("getBuildingHeightScale");
    buildingHeightScale = result;
    return result;
  }

  @override
  Future<void> setBuildingHeightScale(double scale) async {
    await channel.invokeMethod("setBuildingHeightScale", {"scale": scale});
    buildingHeightScale = scale;
  }

  @override
  Future<void> _defaultGUIvisible(DefaultGUIType type, bool visible) async {
    await channel.invokeMethod(
        "defaultGUIvisible", {"type": type.value, "visible": visible});
  }

  @override
  Future<void> _defaultGUIposition(
      DefaultGUIType type, MapGravity gravity, double x, double y) async {
    await channel.invokeMethod("defaultGUIposition",
        {"type": type.value, "gravity": gravity.value, "x": x, "y": y});
  }

  @override
  Future<void> _scaleAutohide(bool autohide) async {
    await channel.invokeMethod("scaleAutohide", {"autohide": autohide});
  }

  @override
  Future<void> _scaleAnimationTime(
      int fadeIn, int fadeOut, int retention) async {
    await channel.invokeMethod("scaleAnimationTime", {
      "fadeIn": fadeIn,
      "fadeOut": fadeOut,
      "retention": retention,
    });
  }

  @override
  Compass get compass => Compass._(controller: this);

  @override
  ScaleBar get scaleBar => ScaleBar._(controller: this);

  @override
  Logo get logo => Logo._(controller: this);

  @override
  Future<String> addPoiStyle(PoiStyle style) async {
    if ((style.id != null && _poiStyle.containsKey(style.id)) ||
        style._isAdded) {
      throw DuplicatedOverlayException(style.id!);
    }
    String styleId = await labelLayer._invokeMethod(
        "addPoiStyle", {"styleId": style.id, "styles": style.toMessageable()});
    style._setStyleId(styleId);
    style._isAdded = true;
    _poiStyle[styleId] = style;
    return styleId;
  }

  @override
  Future<String> addPolygonShapeStyle(PolygonStyle style) async {
    if (style.id != null && _polygonStyle.containsKey(style.id)) {
      throw DuplicatedOverlayException(style.id!);
    }
    final styleIds = await addMultiplePolygonShapeStyle([style], style.id);
    return styleIds;
  }

  @override
  Future<String> addPolylineShapeStyle(
      PolylineStyle style, PolylineCap polylineCap) async {
    if (style.id != null && _polylineStyle.containsKey(style.id)) {
      throw DuplicatedOverlayException(style.id!);
    }
    final styleIds =
        await addMultiplePolylineShapeStyle([style], polylineCap, style.id);
    return styleIds;
  }

  @override
  Future<String> addMultiplePolygonShapeStyle(List<PolygonStyle> style,
      [String? id]) async {
    if ((id != null && _polygonStyle.containsKey(id)) || style.first._isAdded) {
      throw DuplicatedOverlayException(id ?? "NONE_POLYGON_STYLE_ID");
    }
    String styleId = await shapeLayer._invokeMethod("addPolygonShapeStyle", {
      "styleId": id,
      "styles": style.map((e) => e.toMessageable()).toList()
    });
    for (PolygonStyle element in style) {
      element._isAdded = true;
      element._setStyleId(styleId);
    }
    _polygonStyle[styleId] = style;
    return styleId;
  }

  @override
  Future<String> addMultiplePolylineShapeStyle(
      List<PolylineStyle> style, PolylineCap polylineCap,
      [String? id]) async {
    if ((id != null && _polylineStyle.containsKey(id)) ||
        style.first._isAdded) {
      throw DuplicatedOverlayException(id ?? "NONE_POLYLINE_STYLE_ID");
    }
    String styleId = await shapeLayer._invokeMethod("addPolylineShapeStyle", {
      "styleId": id,
      "styles": style.map((e) => e.toMessageable()).toList(),
      "polylineCap": polylineCap.value
    });
    for (PolylineStyle element in style) {
      element._isAdded = true;
      element._setStyleId(styleId);
    }
    _polylineStyle[styleId] = style;
    return styleId;
  }

  @override
  Future<String> addRouteStyle(RouteStyle style) async {
    final styleIds = await addMultipleRouteStyle([style], style.id);
    return styleIds;
  }

  @override
  Future<String> addMultipleRouteStyle(List<RouteStyle> styles,
      [String? id]) async {
    if ((id != null && _routeStyle.containsKey(id)) || styles.first._isAdded) {
      throw DuplicatedOverlayException(id ?? "NONE_POLYGON_STYLE_ID");
    }
    String styleId = await routeLayer._invokeMethod("addRouteStyle", {
      "styleId": id,
      "styles": styles.map((e) => e.toMessageable()).toList()
    });
    for (RouteStyle element in styles) {
      element._isAdded = true;
      element._setStyleId(styleId);
    }
    _routeStyle[styleId] = styles;
    return styleId;
  }

  @override
  PoiStyle? getPoiStyle(String id) => _poiStyle[id];

  @override
  PolygonStyle? getPolygonShapeStyle(String id) => _polygonStyle[id]?[0];

  @override
  PolylineStyle? getPolylineShapeStyle(String id) => _polylineStyle[id]?[0];

  @override
  List<PolygonStyle>? getMultiplePolygonShapeStyle(String id) =>
      _polygonStyle[id];

  @override
  List<PolylineStyle>? getMultiplePolylineShapeStyle(String id) =>
      _polylineStyle[id];

  @override
  RouteStyle? getRotueStyle(String id) => _routeStyle[id]?[0];

  @override
  List<RouteStyle>? getMultipleRotueStyle(String id) => _routeStyle[id];

  @override
  Future<LabelController> addLabelLayer(String id,
      {CompetitionType competitionType =
          BaseLabelController.defaultCompetitionType,
      CompetitionUnit competitionUnit =
          BaseLabelController.defaultCompetitionUnit,
      OrderingType orderingType = BaseLabelController.defaultOrderingType,
      int zOrder = BaseLabelController.defaultZOrder}) async {
    if (_labelController.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final labelLayer = LabelController._(
      overlayChannel,
      this,
      id,
      competitionType: competitionType,
      competitionUnit: competitionUnit,
      orderingType: orderingType,
      zOrder: zOrder,
    );
    await labelLayer._createLabelLayer();
    _labelController[id] = labelLayer;
    return labelLayer;
  }

  @override
  Future<LodLabelController> addLodLabelLayer(String id,
      {CompetitionType competitionType =
          BaseLabelController.defaultCompetitionType,
      CompetitionUnit competitionUnit =
          BaseLabelController.defaultCompetitionUnit,
      OrderingType orderingType = BaseLabelController.defaultOrderingType,
      double radius = LodLabelController.defaultRadius,
      int zOrder = BaseLabelController.defaultZOrder}) async {
    if (_lodLabelController.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final labelLayer = LodLabelController._(
      overlayChannel,
      this,
      id,
      competitionType: competitionType,
      competitionUnit: competitionUnit,
      orderingType: orderingType,
      radius: radius,
      zOrder: zOrder,
    );
    await labelLayer._createLodLabelLayer();
    _lodLabelController[id] = labelLayer;
    return labelLayer;
  }

  @override
  Future<ShapeController> addShapeLayer(String id,
      {ShapeLayerPass passType = ShapeController.defaultShapeLayerPass,
      int zOrder = ShapeController.defaultZOrder}) async {
    if (_shapeController.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final shapeLayer = ShapeController._(overlayChannel, this, id,
        passType: passType, zOrder: zOrder);
    await shapeLayer._createShapeLayer();
    _shapeController[id] = shapeLayer;
    return shapeLayer;
  }

  @override
  Future<RouteController> addRouteLayer(String id,
      {int zOrder = ShapeController.defaultZOrder}) async {
    if (_routeController.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final routeLayer =
        RouteController._(overlayChannel, this, id, zOrder: zOrder);
    await routeLayer._createRouteLayer();
    _routeController[id] = routeLayer;
    return routeLayer;
  }

  @override
  LabelController? getLabelLayer(String id) => _labelController[id];

  @override
  LodLabelController? getLodLabelLayer(String id) => _lodLabelController[id];

  @override
  ShapeController? getShapeLayer(String id) => _shapeController[id];

  @override
  RouteController? getRouteLayer(String id) => _routeController[id];

  @override
  Future<void> removeLabelLayer(LabelController controller) async {
    await controller._removeLabelLayer();
  }

  @override
  Future<void> removeLodLabelLayer(LodLabelController controller) async {
    await controller._removeLodLabelLayer();
  }

  @override
  Future<void> removeShapeLayer(ShapeController controller) async {
    await controller._removeShapeLayer();
  }

  @override
  Future<void> removeRouteLayer(RouteController controller) async {
    await controller._removeRouteLayer();
  }

  @override
  LabelController get labelLayer =>
      _labelController[LabelController.defaultId]!;

  @override
  LodLabelController get lodLabelLayer =>
      _lodLabelController[LodLabelController.defaultId]!;

  @override
  ShapeController get shapeLayer =>
      _shapeController[ShapeController.defaultId]!;

  @override
  RouteController get routeLayer =>
      _routeController[RouteController.defaultId]!;

  @override
  Future<void> finish() async {
    await channel.invokeMethod("finish");
  }

  @override
  Future<void> pause() async {
    await channel.invokeMethod("pause");
  }

  @override
  Future<void> resume() async {
    await channel.invokeMethod("resume");
  }
}
