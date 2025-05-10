part of '../kakao_map_sdk_web.dart';

class WebOverlayController {
  final MethodChannel channel;
  final WebMapController controller;
  final Uuid _uuid;

  final Map<String, PoiStyle> _poiStyles = {};
  final Map<String, List<PolygonStyle>> _polygonStyles = {};
  final Map<String, List<PolylineStyle>> _polylineStyles = {};
  final Map<String, List<RouteStyle>> _routeStyles = {};

  final Map<String, WebLabelController> _labelLayer = {};
  final Map<String, WebLabelController> _lodLabelLayer = {};
  final Map<String, WebShapeController> _shapeLayer = {};
  final Map<String, WebRouteController> _routeLayer = {};

  final void Function(String layerId, String poiId)? onPoiClick;
  final void Function(String layerId, String poiId)? onLodPoiClick;

  WebOverlayController(
      this.channel, this.controller, this.onPoiClick, this.onLodPoiClick)
      : _uuid = const Uuid() {
    initalizeOverlayLayer();
    channel.setMethodCallHandler(overlayHandle);
  }

  void initalizeOverlayLayer() {
    _labelLayer[LabelController.defaultId] = WebLabelController._(
        LabelController.defaultId, controller, this, false);
    _lodLabelLayer[LodLabelController.defaultId] = WebLabelController._(
        LodLabelController.defaultId, controller, this, true);
    _shapeLayer[ShapeController.defaultId] =
        WebShapeController._(ShapeController.defaultId, controller, this);
    _routeLayer[RouteController.defaultId] =
        WebRouteController._(RouteController.defaultId, controller, this);

    _labelLayer[LabelController.defaultId]!.createLabelLayer();
    _lodLabelLayer[LodLabelController.defaultId]!.createLabelLayer();
    _shapeLayer[ShapeController.defaultId]!.createShapeLayer();
    _routeLayer[RouteController.defaultId]!.createRouteLayer();
  }

  void _onPoiClick(String layerId, String poiId, bool isLod) {
    if (isLod) {
      onLodPoiClick?.call(layerId, poiId);
    } else {
      onPoiClick?.call(layerId, poiId);
    }
  }

  Future<dynamic> overlayHandle(MethodCall method) async {
    final argument = method.arguments;
    final type =
        OverlayType.values.firstWhere((e) => e.value == argument["type"]);
    final layerId =
        argument.containsKey("layerId") ? argument["layerId"] : null;

    switch (method.method) {
      case "createLabelLayer":
        _labelLayer[layerId!] =
            WebLabelController._(layerId!, controller, this, false);
        break;
      case "createLodLabelLayer":
        _lodLabelLayer[layerId!] =
            WebLabelController._(layerId!, controller, this, true);
        break;
      case "createRouteLayer":
        _routeLayer[layerId!] =
            WebRouteController._(layerId!, controller, this);
        break;
      case "createShapeLayer":
        _shapeLayer[layerId!] =
            WebShapeController._(layerId!, controller, this);
        break;
      case "removeLabelLayer":
        _labelLayer[layerId!]!.removeLabelLayer();
        _labelLayer.remove(layerId!);
        return;
      case "removeLodLabelLayer":
        _lodLabelLayer[layerId!]!.removeLabelLayer();
        _lodLabelLayer.remove(layerId!);
        return;
      case "removeRouteLayer":
        _routeLayer[layerId!]!.removeRouteLayer();
        _routeLayer.remove(layerId!);
        return;
      case "addPoiStyle":
        final poiStyleId = argument["styleId"] ?? _uuid.v4();
        _poiStyles[poiStyleId] =
            PoiStyle.fromMessageable(argument["styles"], poiStyleId);
        return poiStyleId;
      case "addRouteStyle":
        final routeStyleId = argument["styleId"] ?? _uuid.v4();
        _routeStyles[routeStyleId] = argument["styles"]
            .map<RouteStyle>((e) => RouteStyle.fromMessageable(e, routeStyleId))
            .toList();
        return routeStyleId;
      case "addPolylineShapeStyle":
        final polylineStyleId = argument["styleId"] ?? _uuid.v4();
        _polylineStyles[polylineStyleId] = argument["styles"]
            .map<PolylineStyle>((payload) =>
                PolylineStyle.fromMessageable(payload, polylineStyleId))
            .toList();
        return polylineStyleId;
      case "addPolygonShapeStyle":
        final polygonStyleId = argument["styleId"] ?? _uuid.v4();
        _polygonStyles[polygonStyleId] = argument["styles"]
            .map<PolygonStyle>((payload) =>
                PolygonStyle.fromMessageable(payload, polygonStyleId))
            .toList();
        return polygonStyleId;
    }

    switch (type) {
      case OverlayType.label || OverlayType.lodLabel:
        WebLabelController? layer = _labelLayer[layerId!];
        layer = layer ?? _lodLabelLayer[layerId!];
        return await layer?.labelHandle(method);
      case OverlayType.shape:
        return await _shapeLayer[layerId!]?.shapeHandle(method);
      case OverlayType.route:
        return await _routeLayer[layerId!]?.routeHandle(method);
    }
  }
}
