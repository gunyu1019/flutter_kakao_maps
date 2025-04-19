part of '../kakao_map_sdk.dart';

/// [KakaoMapController]를 웹 환경에서 사용할 수 있도록 구현하는 객체입니다.
class KakaoMapWebController extends KakaoMapController {
  // ignore: constant_identifier_names
  static const VIEW_TYPE = "plugin/kakao_map";

  final WebMapController controller;
  final KakaoMapControllerHandler handler;

  /// Android(Kotlin), iOS(Swift) 플랫폼에서는 고유 네이티브 환경간 소통할 수 있는 [MethodChannel]이 필요합니다.
  /// Web 환경에서는 네이티브 고유 언어와 소통할 플랫폼 채널이 필요 없으므로 더미 채널을 만듭니다.
  /// 더미 채널은 오버레이 플랫폼 채널 역할을 대신합니다. 실제로 쓰이지는 않습니다.
  final MethodChannel _dummyChannel;

  KakaoMapWebController({
    required this.controller,
    required this.handler,
  }) : _dummyChannel = const MethodChannel("dummy_method_channel");

  /// 네이티브 환경에서 줌 레벨과 웹 환경에서 줌 레벨을 계산합니다.
  /// 아래의 공식은 축적도를 기반으로 계산된 줌 레벨이며 플랫폼별 제공하는 SDK 한계상 오차가 발생할 수 있습니다.
  /// Android, iOS Platform: Lv.6 ~ Lv.21 (Lv.19)
  /// Web Platform: Lv.1 ~ Lv.14
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
      int zOrder = BaseLabelController.defaultZOrder}) async {
    final layer = WebLabelController._(controller, _dummyChannel, this, id);
    _labelController[id] = layer;
    return layer;
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
  Future<void> clearCache() async {}

  @override
  Future<void> clearDiskCache() async {}

  @override
  Compass get compass => Compass._(controller: this);

  @override
  Future<double> fetchBuildingHeightScale() async {
    return 0.0;
  }

  @override
  Future<LatLng?> fromScreenPoint(int x, int y) async {
    final protection = controller.getProjection();
    return protection
        .coordsFromContainerPoint(WebPoint(x.toDouble(), y.toDouble()))
        .toLatLng();
  }

  @override
  Future<CameraPosition> getCameraPosition() async {
    return CameraPosition(
        controller.getCenter().toLatLng(), controller.getLevel());
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
  Future<void> hideOverlay(MapOverlay overlay) async {
    final mapTypeId = switch (overlay) {
      MapOverlay.bicycleRoad => 8,
      MapOverlay.roadviewLine => 5,
      MapOverlay.hillsading => 7,
      MapOverlay.hybrid => 3,
    };
    controller.removeOverlayMapTypeId(mapTypeId);
  }

  @override
  // TODO: implement labelLayer
  LabelController get labelLayer => WebLabelController._(
      controller, const MethodChannel("dummy"), this, "default");

  @override
  // TODO: implement lodLabelLayer
  LodLabelController get lodLabelLayer => throw UnimplementedError();

  @override
  Logo get logo => Logo._(controller: this);

  @override
  Future<void> moveCamera(CameraUpdate camera,
      {CameraAnimation? animation}) async {
    JSAny animationOption = {
      "animate": animation == null ? false : {"duration": animation.duration}
    }.jsify()!;
    web.console.log(animationOption);
    final level = controller.getLevel();
    switch (camera.type) {
      case CameraUpdateType.newCenterPoint:
        final zoomLevel = camera.zoomLevel == -1
            ? level
            : calculateZoomLevel(camera.zoomLevel);
        controller.jump(
            WebLatLng.fromLatLng(camera.position!), zoomLevel, animationOption);
        break;
      case CameraUpdateType.newCameraPos:
        final zoomLevel = camera.cameraPosition!.zoomLevel == -1
            ? level
            : calculateZoomLevel(camera.cameraPosition!.zoomLevel);
        controller.jump(WebLatLng.fromLatLng(camera.cameraPosition!.position),
            zoomLevel, animationOption);
        break;
      case CameraUpdateType.zoomTo:
        final zoomLevel = camera.zoomLevel == -1
            ? level
            : calculateZoomLevel(camera.zoomLevel);
        controller.setLevel(zoomLevel, {"options": animationOption}.jsify());
        break;
      case CameraUpdateType.zoomIn:
        controller.setLevel(level - 1, {"options": animationOption}.jsify());
        break;
      case CameraUpdateType.zoomOut:
        controller.setLevel(level + 1, {"options": animationOption}.jsify());
        break;
      case CameraUpdateType.newCameraAngle:
      case CameraUpdateType.rotate:
      case CameraUpdateType.tilt:
        break;
      case CameraUpdateType.fitMapPoints:
        final bounds = WebLatLngBound();
        camera.fitPoints!
            .map((e) => WebLatLng.fromLatLng(e))
            .forEach((e) => bounds.extend(e));
        controller.setBounds(bounds, camera.padding ?? 0, camera.padding ?? 0,
            camera.padding ?? 0, camera.padding ?? 0);
    }
  }

  @override
  MethodChannel get overlayChannel => _dummyChannel;

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
  ScaleBar get scaleBar => ScaleBar._(controller: this);

  @override
  Future<void> setBuildingHeightScale(double scale) async {}

  @override
  Future<void> setGesture(GestureType gesture, bool enable) {
    // TODO: implement setGesture
    throw UnimplementedError();
  }

  @override
  // TODO: implement shapeLayer
  ShapeController get shapeLayer => throw UnimplementedError();

  @override
  Future<void> showOverlay(MapOverlay overlay) async {
    final mapTypeId = switch (overlay) {
      MapOverlay.bicycleRoad => 8,
      MapOverlay.roadviewLine => 5,
      MapOverlay.hillsading => 7,
      MapOverlay.hybrid => 3,
    };
    controller.addOverlayMapTypeId(mapTypeId);
  }

  @override
  Future<KPoint?> toScreenPoint(LatLng position) async {
    final protection = controller.getProjection();
    return protection
        .containerPointFromCoords(WebLatLng.fromLatLng(position))
        .toPoint();
  }

  @override
  Future<void> _defaultGUIposition(
      DefaultGUIType type, MapGravity gravity, double x, double y) async {
    if (type != DefaultGUIType.compass &&
        gravity.verticalAlign == VerticalAlign.bottom) {
      final position = switch (gravity.horizontalAlign) {
        HorizontalAlign.left => 0,
        HorizontalAlign.center => -1,
        HorizontalAlign.right => 1,
      };
      if (position >= 0) {
        controller.setCopyrightPosition(position, false);
      }
    }
  }

  @override
  Future<void> _defaultGUIvisible(DefaultGUIType type, bool visible) async {}

  @override
  Future<void> _scaleAnimationTime(
      int fadeIn, int fadeOut, int retention) async {}

  @override
  Future<void> _scaleAutohide(bool autohide) async {}
}
