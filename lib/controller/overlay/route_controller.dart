part of '../../kakao_map_sdk.dart';

/// 지도에 [Route] 또는 [MultipleRoute]를 생성하거나 삭제하는 등의 개체 관리를 할 수 있는 컨트롤러입니다.
class RouteController extends OverlayController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.route;

  /// [RouteController]의 고유 ID입니다.
  final String id;

  /// 렌더링의 우선순위를 정의합니다.
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
    await _invokeMethod("changeRoute", {
      "routeId": routeId,
      "points": points
          .map((e1) => e1.map((e2) => e2.toMessageable()).toList())
          .toList(),
      "styleId": styleId,
      "curveType": curveType.map((e) => e.value).toList(),
    });
  }

  Future<void> _changeRouteZOrder(String routeId, int zOrder) async {
    await _invokeMethod("changeRouteZOrder", {
      "routeId": routeId,
      "zOrder": zOrder
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

  /// 지도에 새로운 단일 선형([Route])을 그립니다.
  /// [Route]를 그리기 위해서는 지점([points])과 스타일([style])이 필수로 입력되어야 합니다.
  /// Route에서 사용되는 [id]는 이미 등록된 [MultipleRoute.id]와 중복될 수 없습니다.
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

  /// 지도에 새로운 다중 선형([MultipleRoute])을 그립니다.
  /// [MultipleRouteOption.id]는 이미 등록된 [Route]의 ID와 중복될 수 없습니다.
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

  /// 입력된 [id]에 따라 지도에 그려진 [Route]를 불러옵니다.
  Route? getRoute(String id) => _route[id];

  /// 입력된 [id]에 따라 지도에 그려진 [MultipleRoute]를 불러옵니다.
  MultipleRoute? getMultipleRoute(String id) => _multipleRoute[id];

  /// 입력된 [route]에 따라 지도에 그려진 [Route]를 삭제합니다.
  Future<void> removeRoute(Route route) async {
    await _invokeMethod("removeRoute", {"routeId": route.id});
    _route.remove(route.id);
  }

  /// 입력된 [route]에 따라 지도에 그려진 [MultipleRoute]를 삭제합니다.
  Future<void> removeMultipleRoute(MultipleRoute route) async {
    await _invokeMethod("removeRoute", {"routeId": route.id});
    _multipleRoute.remove(route.id);
  }

  static const String defaultId = "route_layer_0";
  static const int defaultZOrder = 10000;
}
