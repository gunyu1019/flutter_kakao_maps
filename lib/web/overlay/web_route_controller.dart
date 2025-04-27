part of '../../kakao_map_sdk.dart';

class WebRouteController extends RouteController {
  final WebMapController controller;

  final Map<String, List<WebRoute>> _webRoute = {};
  final Map<String, int> _currentRouteLevel = {};

  WebRouteController._(this.controller, super.channel, super.manager, super.id)
      : super._();

  @override
  Future<void> _createRouteLayer() async {}

  @override
  Future<void> _removeRouteLayer() async {
    for (final route in _route.values) {
      await removeRoute(route);
    }
  }

  @override
  Future<void> _changeMultipleRoute(
      String routeId, String styleId, List<RouteSegment> segments) async {}

  @override
  Future<void> _changeRoute(String routeId, String styleId, CurveType curveType,
      List<LatLng> points) async {}

  @override
  Future<void> _changeRouteVisible(String routeId, bool visible) async {
    for (final route in _webRoute[routeId]!) {
      if (visible) {
        route.bodyElement.setMap(controller);
        route.strokeElement?.setMap(controller);
        route.patternElement?.setMap(controller);
      }
      else {
        route.bodyElement.setMap(null);
        route.strokeElement?.setMap(null);
        route.patternElement?.setMap(null);
      }
    }
  }

  static String _getSingleColorCode(double value) =>
      (value * 255).toInt().toRadixString(16);

  static String getColorCode(Color color) =>
      "#${_getSingleColorCode(color.r)}${_getSingleColorCode(color.g)}${_getSingleColorCode(color.b)}";

  WebRoute _addRouteElement(RouteStyle style, List<LatLng> points, int zOrder) {
    final bodyElementOption = WebPolylineOption(
        path: points.map(WebLatLng.fromLatLng).toList().toJS,
        strokeWeight: style.lineWidth * .5,
        strokeColor: getColorCode(style.color),
        strokeOpacity: 1,
        zIndex: zOrder);
    final strokeElementOption = style.strokeWidth > 0
        ? WebPolylineOption(
            path: points.map(WebLatLng.fromLatLng).toList().toJS,
            strokeWeight: style.lineWidth * .5 + style.strokeWidth * .5,
            strokeColor: getColorCode(style.strokeColor),
            strokeOpacity: 1,
            zIndex: zOrder - 1)
        : null;
    final patternElementOption = style.pattern == null
        ? WebPolylineOption(
            path: points.map(WebLatLng.fromLatLng).toList().toJS,
            strokeWeight: 1,
            strokeColor: getColorCode(style.strokeColor),
            strokeOpacity: 1,
            strokeStyle: "longdash",
            zIndex: zOrder + 1)
        : null;

    final bodyElement = WebPolyline(bodyElementOption);
    final strokeElement =
        strokeElementOption != null ? WebPolyline(strokeElementOption) : null;
    final patternElement =
        patternElementOption != null ? WebPolyline(patternElementOption) : null;
    strokeElement?.setMap(controller);
    bodyElement.setMap(controller);
    patternElement?.setMap(controller);
    return WebRoute(bodyElement, strokeElement, patternElement, bodyElementOption,
          strokeElementOption, patternElementOption);
  }

  @override
  Future<Route> addRoute(List<LatLng> points, RouteStyle style,
      {String? id,
      CurveType curveType = CurveType.none,
      int zOrder = 10000}) async {
    if (id != null && _route.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    style.id ?? await manager.addRouteStyle(style);

    String routeId = "route_overlay_${id}_${_route.length}";
    _webRoute[routeId] = [_addRouteElement(style, points, zOrder)];

    final route = Route._(this, routeId,
        points: points, style: style, curveType: curveType, zOrder: zOrder);
    _route[routeId] = route;
    return route;
  }

  @override
  Future<MultipleRoute> addMultipleRoute(MultipleRouteOption option) async {
    if (option.id != null && _route.containsKey(option.id)) {
      throw DuplicatedOverlayException(option.id!);
    }
    if (!option._isStyleAdded()) {
      await manager.addMultipleRouteStyle(option.styles);
    }

    String routeId = "multiple_route_overlay_${id}_${_route.length}";

    final route = MultipleRoute._(this, routeId,
        segments: option.segments,
        styles: option.styles,
        zOrder: option.zOrder);
    _route[routeId] = route;
    return route;
  }

  @override
  Future<void> removeRoute(BaseRoute route) async {
    await _changeRouteVisible(route.id, false);
    _route.remove(route.id);
    _webRoute.remove(route.id);
  }

  @override
  Future<void> showAllRoute() async {
    for (var route in _route.values) {
      await route.show();
    }
  }

  @override
  Future<void> hideAllRoute() async { 
    for (var route in _route.values) {
      await route.hide();
    }
  }
}
