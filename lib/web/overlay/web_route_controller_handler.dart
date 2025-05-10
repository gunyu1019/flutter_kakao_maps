part of '../kakao_map_sdk_web.dart';

mixin WebRouteControllerHandler {
  WebOverlayController get manager;

  Future<dynamic> routeHandle(MethodCall method) async {
    final arguments = method.arguments;
    final routeId = arguments["routeId"];

    switch (method.method) {
      case "createRouteLayer":
        await createRouteLayer();
        break;
      case "removeRouteLayer":
        await removeRouteLayer();
        break;
      case "addRoute":
        final route = arguments["route"];
        final points =
            route["points"].map<LatLng>(LatLng.fromMessageable).toList();
        final style = manager._routeStyles[route["styleId"]!]![0];
        final curveType =
            CurveType.values.firstWhere((e) => e.value == route["curveType"]);
        return await addRoute(points, style,
            id: route["id"], curveType: curveType, zOrder: route["zOrder"]);
      case "addMultipleRoute":
        final route = arguments["route"];
        final styleId = route["routes"][0]["styleId"]!;
        final styles = manager._routeStyles[styleId]!;
        final option = MultipleRouteOption.fromMessageable(route, styles);
        return await addMultipleRoute(option);
      case "removeRoute":
        await removeRoute(routeId);
        break;
      case "changeRoute":
        final styleId = arguments["styleId"];
        List<List<LatLng>> point0 = [];
        for (final point in arguments["points"]) {
          point0.add(point.map<LatLng>(LatLng.fromMessageable).toList());
        }
        await changeRoute(routeId, styleId, point0);
        break;
      case "changeRouteVisible":
        await changeRouteVisible(routeId, arguments["visible"]);
        break;
      case "changeRouteZOrder":
        await changeRouteZOrder(routeId, arguments["zOrder"]);
        break;
      case "changeVisibleAllRoute":
        if (arguments["visible"]) {
          await showAllRoute();
        } else {
          await hideAllRoute();
        }
        break;
      default:
        throw UnimplementedError();
    }
  }

  Future<void> createRouteLayer();

  Future<void> removeRouteLayer();

  Future<String> addRoute(List<LatLng> points, RouteStyle style,
      {String? id, CurveType curveType = CurveType.none, int zOrder = 10000});

  Future<String> addMultipleRoute(MultipleRouteOption option);

  Future<void> removeRoute(String routeId);

  Future<void> changeRoute(
      String routeId, String styleId, List<List<LatLng>> points);

  Future<void> changeRouteVisible(String routeId, bool visible);

  Future<void> changeRouteZOrder(String routeId, int zOrder);

  Future<void> showAllRoute();

  Future<void> hideAllRoute();
}
