// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../kakao_map_sdk.dart';

class KakaoMapWebController extends KakaoMapController {
  // ignore: constant_identifier_names
  static const VIEW_TYPE = "plugin/kakao_map";

  final WebMapController controller;
  final KakaoMapControllerHandler handler;

  KakaoMapWebController({
    required this.controller,
    required this.handler,
  });

  // Android, iOS Platform: Lv.1 ~ Lv.21 (Lv.19)
  // Web Platform: Lv.1 ~ Lv.14
  static int calculateZoomLevel(int level) => switch (level) {
        >= 18 => 1,
        >= 17 && <= 16 => 19 - level,
        >= 15 && <= 7 => 20 - level,
        <= 6 => 14,
        int() => 3
      };

  @override
  Future<LabelController> addLabelLayer(String id,
      {CompetitionType competitionType =
          BaseLabelController.defaultCompetitionType,
      CompetitionUnit competitionUnit =
          BaseLabelController.defaultCompetitionUnit,
      OrderingType orderingType = BaseLabelController.defaultOrderingType,
      int zOrder = BaseLabelController.defaultZOrder}) {
    // TODO: implement addLabelLayer
    throw UnimplementedError();
  }

  @override
  Future<LodLabelController> addLodLabelLayer(String id,
      {CompetitionType competitionType =
          BaseLabelController.defaultCompetitionType,
      CompetitionUnit competitionUnit =
          BaseLabelController.defaultCompetitionUnit,
      OrderingType orderingType = BaseLabelController.defaultOrderingType,
      double radius = LodLabelController.defaultRadius,
      int zOrder = BaseLabelController.defaultZOrder}) {
    // TODO: implement addLodLabelLayer
    throw UnimplementedError();
  }

  @override
  Future<String> addMultiplePolygonShapeStyle(List<PolygonStyle> style,
      [String? id]) {
    // TODO: implement addMultiplePolygonShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addMultiplePolylineShapeStyle(
      List<PolylineStyle> style, PolylineCap polylineCap,
      [String? id]) {
    // TODO: implement addMultiplePolylineShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addMultipleRouteStyle(List<RouteStyle> styles, [String? id]) {
    // TODO: implement addMultipleRouteStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addPoiStyle(PoiStyle style) async {
    final poiStyleId = "poi_style_${_poiStyle.length}";
    _poiStyle[poiStyleId] = style;
    return poiStyleId;
  }

  @override
  Future<String> addPolygonShapeStyle(PolygonStyle style) {
    // TODO: implement addPolygonShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addPolylineShapeStyle(
      PolylineStyle style, PolylineCap polylineCap) {
    // TODO: implement addPolylineShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<RouteController> addRouteLayer(String id,
      {int zOrder = RouteController.defaultZOrder}) {
    // TODO: implement addRouteLayer
    throw UnimplementedError();
  }

  @override
  Future<String> addRouteStyle(RouteStyle style) {
    // TODO: implement addRouteStyle
    throw UnimplementedError();
  }

  @override
  Future<ShapeController> addShapeLayer(String id,
      {ShapeLayerPass passType = ShapeController.defaultShapeLayerPass,
      int zOrder = ShapeController.defaultZOrder}) {
    // TODO: implement addShapeLayer
    throw UnimplementedError();
  }

  @override
  Future<bool> canShowPosition(int zoomLevel, List<LatLng> position) {
    // TODO: implement canShowPosition
    throw UnimplementedError();
  }

  @override
  Future<void> changeMapType(MapType mapType) {
    // TODO: implement changeMapType
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() {
    // TODO: implement clearCache
    throw UnimplementedError();
  }

  @override
  Future<void> clearDiskCache() {
    // TODO: implement clearDiskCache
    throw UnimplementedError();
  }

  @override
  // TODO: implement compass
  Compass get compass => throw UnimplementedError();

  @override
  Future<double> fetchBuildingHeightScale() async {
    return 0.0;
  }

  @override
  Future<LatLng?> fromScreenPoint(int x, int y) {
    // TODO: implement fromScreenPoint
    throw UnimplementedError();
  }

  @override
  Future<CameraPosition> getCameraPosition() {
    // TODO: implement getCameraPosition
    throw UnimplementedError();
  }

  @override
  LabelController? getLabelLayer(String id) => _labelController[id];

  @override
  LodLabelController? getLodLabelLayer(String id) => _lodLabelController[id];

  @override
  List<PolygonStyle>? getMultiplePolygonShapeStyle(String id) =>
      _polygonStyle[id];

  @override
  List<PolylineStyle>? getMultiplePolylineShapeStyle(String id) =>
      _polylineStyle[id];

  @override
  List<RouteStyle>? getMultipleRotueStyle(String id) => _routeStyle[id];

  @override
  PoiStyle? getPoiStyle(String id) => _poiStyle[id];

  @override
  PolygonStyle? getPolygonShapeStyle(String id) =>
      getMultiplePolygonShapeStyle(id)?[0];

  @override
  PolylineStyle? getPolylineShapeStyle(String id) =>
      getMultiplePolylineShapeStyle(id)?[0];

  @override
  RouteStyle? getRotueStyle(String id) => getMultipleRotueStyle(id)?[0];

  @override
  RouteController? getRouteLayer(String id) => _routeController[id];

  @override
  ShapeController? getShapeLayer(String id) => _shapeController[id];

  @override
  Future<void> hideOverlay(MapOverlay overlay) {
    // TODO: implement hideOverlay
    throw UnimplementedError();
  }

  @override
  // TODO: implement labelLayer
  LabelController get labelLayer => WebLabelController._(controller, const MethodChannel("dummy"), this, "default");

  @override
  // TODO: implement lodLabelLayer
  LodLabelController get lodLabelLayer => throw UnimplementedError();

  @override
  // TODO: implement logo
  Logo get logo => throw UnimplementedError();

  @override
  Future<void> moveCamera(CameraUpdate camera, {CameraAnimation? animation}) {
    // TODO: implement moveCamera
    throw UnimplementedError();
  }

  @override
  // TODO: implement overlayChannel
  MethodChannel get overlayChannel => throw UnimplementedError();

  @override
  Future<void> removeLabelLayer(LabelController controller) {
    // TODO: implement removeLabelLayer
    throw UnimplementedError();
  }

  @override
  Future<void> removeLodLabelLayer(LodLabelController controller) {
    // TODO: implement removeLodLabelLayer
    throw UnimplementedError();
  }

  @override
  Future<void> removeRouteLayer(RouteController controller) {
    // TODO: implement removeRouteLayer
    throw UnimplementedError();
  }

  @override
  Future<void> removeShapeLayer(ShapeController controller) {
    // TODO: implement removeShapeLayer
    throw UnimplementedError();
  }

  @override
  // TODO: implement routeLayer
  RouteController get routeLayer => throw UnimplementedError();

  @override
  // TODO: implement scaleBar
  ScaleBar get scaleBar => throw UnimplementedError();

  @override
  Future<void> setBuildingHeightScale(double scale) {
    // TODO: implement setBuildingHeightScale
    throw UnimplementedError();
  }

  @override
  Future<void> setGesture(GestureType gesture, bool enable) {
    // TODO: implement setGesture
    throw UnimplementedError();
  }

  @override
  // TODO: implement shapeLayer
  ShapeController get shapeLayer => throw UnimplementedError();

  @override
  Future<void> showOverlay(MapOverlay overlay) {
    // TODO: implement showOverlay
    throw UnimplementedError();
  }

  @override
  Future<KPoint?> toScreenPoint(LatLng position) {
    // TODO: implement toScreenPoint
    throw UnimplementedError();
  }

  @override
  Future<void> _defaultGUIposition(
      DefaultGUIType type, MapGravity gravity, double x, double y) {
    // TODO: implement _defaultGUIposition
    throw UnimplementedError();
  }

  @override
  Future<void> _defaultGUIvisible(DefaultGUIType type, bool visible) async {}

  @override
  Future<void> _scaleAnimationTime(
      int fadeIn, int fadeOut, int retention) async {}

  @override
  Future<void> _scaleAutohide(bool autohide) async {}
}
