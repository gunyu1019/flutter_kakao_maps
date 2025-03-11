part of '../../kakao_map_sdk.dart';

class RouteController extends OverlayController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.route;

  final String id;
  final int zOrder;

  final Map<String, Route> _route = {};
  final Map<String, MultipleRoute> _multipleRoute = {};

  RouteController._(this.channel, this.manager, this.id,
      {this.zOrder = defaultZOrder});

  Future<void> _createRouteLayer() async {
    await _invokeMethod("createRouteLayer", {"zOrder": zOrder});
  }

  Future<void> _removeRouteLayer() async {
    await _invokeMethod("removeRouteLayer", {});
  }

  Future<void> _changeRoute(String routeId, String styleId, List<CurveType> curveType, List<List<LatLng>> points) async {
    await _invokeMethod("changeRoutePoint", {
      "routeId": routeId,
      "points": points
          .map((e1) => e1.map((e2) => e2.toMessageable()).toList())
          .toList(),
      "styleId": styleId,
      "curveType": curveType.map((e) => e.value).toList(),
    });
  }

  Future<void> _changeRouteVisible(String routeId, bool visible) async {
    await _invokeMethod(
        "changeRouteVisible", {"routeId": routeId, "visible": visible});
  }

  @override
  Future<T> _invokeMethod<T>(String method, Map<String, dynamic> payload) {
    payload['layerId'] = id;
    return super._invokeMethod(method, payload);
  }

  Future<Route> addRoute(List<LatLng> points, RouteStyle style,
      {String? id, CurveType curveType = CurveType.none, int zOrder = 10000}) async {
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

  Future<MultipleRoute> addMultipleRoute(MultipleRouteOption option) async {
    if (!option._isStyleAdded()) {
      await manager.addMultipleRouteStyle(option._styles);
    }
    Map<String, dynamic> payload = {"route": option.toMessageable()};
    String routeId = await _invokeMethod("addMultipleRoute", payload);
    final route = MultipleRoute._(this, routeId,
        points: option._points,
        style: option._styles,
        curveType: option._curveType,
        styleIndex: option._styleIndex, 
        zOrder: option.zOrder);
    _multipleRoute[routeId] = route;
    return route;
  }

  Route? getRoute(String id) => _route[id];

  MultipleRoute? getMultipleRoute(String id) => _multipleRoute[id];

  Future<void> removeRoute(Route route) async {
    await _invokeMethod("removeRoute", {"routeId": route.id});
    _route.remove(route.id);
  }

  Future<void> removeMultipleRoute(MultipleRoute route) async {
    await _invokeMethod("removeRoute", {"routeId": route.id});
    _multipleRoute.remove(route.id);
  }

  static const String defaultId = "route_layer_0";
  static const int defaultZOrder = 10000;
}
