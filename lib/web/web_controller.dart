part of '../kakao_map_sdk.dart';


class KakaoMapWebController extends KakaoMapControllerSender {
  // ignore: constant_identifier_names
  static const VIEW_TYPE = "plugin/kakao_map";

  @override
  Future<LabelController> addLabelLayer(String id, {CompetitionType competitionType = BaseLabelController.defaultCompetitionType, CompetitionUnit competitionUnit = BaseLabelController.defaultCompetitionUnit, OrderingType orderingType = BaseLabelController.defaultOrderingType, int zOrder = BaseLabelController.defaultZOrder}) {
    // TODO: implement addLabelLayer
    throw UnimplementedError();
  }

  @override
  Future<LodLabelController> addLodLabelLayer(String id, {CompetitionType competitionType = BaseLabelController.defaultCompetitionType, CompetitionUnit competitionUnit = BaseLabelController.defaultCompetitionUnit, OrderingType orderingType = BaseLabelController.defaultOrderingType, double radius = LodLabelController.defaultRadius, int zOrder = BaseLabelController.defaultZOrder}) {
    // TODO: implement addLodLabelLayer
    throw UnimplementedError();
  }

  @override
  Future<String> addMultiplePolygonShapeStyle(List<PolygonStyle> style, [String? id]) {
    // TODO: implement addMultiplePolygonShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addMultiplePolylineShapeStyle(List<PolylineStyle> style, PolylineCap polylineCap, [String? id]) {
    // TODO: implement addMultiplePolylineShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addMultipleRouteStyle(List<RouteStyle> styles, [String? id]) {
    // TODO: implement addMultipleRouteStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addPoiStyle(PoiStyle style) {
    // TODO: implement addPoiStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addPolygonShapeStyle(PolygonStyle style) {
    // TODO: implement addPolygonShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<String> addPolylineShapeStyle(PolylineStyle style, PolylineCap polylineCap) {
    // TODO: implement addPolylineShapeStyle
    throw UnimplementedError();
  }

  @override
  Future<RouteController> addRouteLayer(String id, {int zOrder = RouteController.defaultZOrder}) {
    // TODO: implement addRouteLayer
    throw UnimplementedError();
  }

  @override
  Future<String> addRouteStyle(RouteStyle style) {
    // TODO: implement addRouteStyle
    throw UnimplementedError();
  }

  @override
  Future<ShapeController> addShapeLayer(String id, {ShapeLayerPass passType = ShapeController.defaultShapeLayerPass, int zOrder = ShapeController.defaultZOrder}) {
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
  Future<double> fetchBuildingHeightScale() {
    // TODO: implement fetchBuildingHeightScale
    throw UnimplementedError();
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
  LabelController? getLabelLayer(String id) {
    // TODO: implement getLabelLayer
    throw UnimplementedError();
  }

  @override
  LodLabelController? getLodLabelLayer(String id) {
    // TODO: implement getLodLabelLayer
    throw UnimplementedError();
  }

  @override
  List<PolygonStyle>? getMultiplePolygonShapeStyle(String id) {
    // TODO: implement getMultiplePolygonShapeStyle
    throw UnimplementedError();
  }

  @override
  List<PolylineStyle>? getMultiplePolylineShapeStyle(String id) {
    // TODO: implement getMultiplePolylineShapeStyle
    throw UnimplementedError();
  }

  @override
  List<RouteStyle>? getMultipleRotueStyle(String id) {
    // TODO: implement getMultipleRotueStyle
    throw UnimplementedError();
  }

  @override
  PoiStyle? getPoiStyle(String id) {
    // TODO: implement getPoiStyle
    throw UnimplementedError();
  }

  @override
  PolygonStyle? getPolygonShapeStyle(String id) {
    // TODO: implement getPolygonShapeStyle
    throw UnimplementedError();
  }

  @override
  PolylineStyle? getPolylineShapeStyle(String id) {
    // TODO: implement getPolylineShapeStyle
    throw UnimplementedError();
  }

  @override
  RouteStyle? getRotueStyle(String id) {
    // TODO: implement getRotueStyle
    throw UnimplementedError();
  }

  @override
  RouteController? getRouteLayer(String id) {
    // TODO: implement getRouteLayer
    throw UnimplementedError();
  }

  @override
  ShapeController? getShapeLayer(String id) {
    // TODO: implement getShapeLayer
    throw UnimplementedError();
  }

  @override
  Future<void> hideOverlay(MapOverlay overlay) {
    // TODO: implement hideOverlay
    throw UnimplementedError();
  }

  @override
  // TODO: implement labelLayer
  LabelController get labelLayer => throw UnimplementedError();

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
  Future<void> _defaultGUIposition(DefaultGUIType type, MapGravity gravity, double x, double y) {
    // TODO: implement _defaultGUIposition
    throw UnimplementedError();
  }
  
  @override
  Future<void> _defaultGUIvisible(DefaultGUIType type, bool visible) {
    // TODO: implement _defaultGUIvisible
    throw UnimplementedError();
  }
  
  @override
  Future<void> _scaleAnimationTime(int fadeIn, int fadeOut, int retention) {
    // TODO: implement _scaleAnimationTime
    throw UnimplementedError();
  }
  
  @override
  Future<void> _scaleAutohide(bool autohide) {
    // TODO: implement _scaleAutohide
    throw UnimplementedError();
  }
}