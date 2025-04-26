part of '../../kakao_map_sdk.dart';

class WebRouteController extends RouteController {
  final WebMapController controller;

  WebRouteController._(this.controller, super.channel, super.manager, super.id)
      : super._();

  @override
  Future<void> _createRouteLayer() async {
  }

  @override
  Future<void> _removeRouteLayer() async {
  }

  @override
  Future<void> _changeMultipleRoute(
      String routeId, String styleId, List<RouteSegment> segments) async {
  }

  @override
  Future<void> _changeRoute(String routeId, String styleId, CurveType curveType,
      List<LatLng> points) async {
  }

  @override
  Future<void> _changeRouteVisible(String routeId, bool visible) async {
  }

  @override
  Future<Route> addRoute(List<LatLng> points, RouteStyle style,
      {String? id,
      CurveType curveType = CurveType.none,
      int zOrder = 10000}) async {
    if (id != null && _route.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final styleId = style.id ?? await manager.addRouteStyle(style);
    Map<String, dynamic> payload = {
      "route": <String, dynamic>{
        "id": id,
        "points": points.map((e) => e.toMessageable()).toList(),
        "styleId": styleId,
        "curveType": curveType.value,
        "zOrder": zOrder
      }
    };
    String routeId = await _invokeMethod("addRoute", payload);
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
    Map<String, dynamic> payload = {"route": option.toMessageable()};
    String routeId = await _invokeMethod("addMultipleRoute", payload);
    final route = MultipleRoute._(this, routeId,
        segments: option.segments,
        styles: option.styles,
        zOrder: option.zOrder);
    _route[routeId] = route;
    return route;
  }
  
  @override
  Future<void> removeRoute(BaseRoute route) async {
    _route.remove(route.id);
  }

  @override
  Future<void> showAllRoute() async {}

  @override
  Future<void> hideAllRoute() async {}
}
