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
  // final Map<String, WebLabelController> _shapeLayer;
  // final Map<String, WebLabelController> _routeLayer;

  WebOverlayController(this.channel, this.controller) : _uuid = const Uuid();

  Future<dynamic> overlayHandle(MethodCall method) async {
    final argument = method.arguments;
    final type = OverlayType.values.firstWhere((e) => e.value == argument["type"]);
    final layerId = argument.containsKey("layerId") ? argument["layerId"] : null;

    WebLabelController? layer;
    switch(method.method) {
      case "createLabelLayer":
        _labelLayer[layerId!] = WebLabelController._(controller);
        break;
      case "createLodLabelLayer":
        _lodLabelLayer[layerId!] = WebLabelController._(controller);
        break;
      case "removeLabelLayer":
        _labelLayer[layerId!]!.removeLabelLayer();
        _labelLayer.remove(layerId!);
        return;
      case "removeLodLabelLayer":
        _lodLabelLayer[layerId!]!.removeLabelLayer();
        _lodLabelLayer.remove(layerId!);
        return;
    }

    switch(type) {
      case OverlayType.label:
        layer = _labelLayer[layerId!];
      case OverlayType.lodLabel:
        layer = layer ?? _lodLabelLayer[layerId!];
        return await layer?.labelHandle(method);
      case OverlayType.shape:
        throw UnimplementedError();
      case OverlayType.route:
        throw UnimplementedError();
    }
  }
}
