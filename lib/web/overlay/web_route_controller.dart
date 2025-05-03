part of '../../kakao_map_sdk.dart';

class WebRouteController extends RouteController {
  final WebMapController controller;

  final Map<String, List<WebRoute>> _webRoute = {};
  final Map<String, List<int>> _currentRouteLevel = {};

  WebRouteController._(this.controller, super.channel, super.manager, super.id)
      : super._();

  @override
  Future<void> _createRouteLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> _removeRouteLayer() async {
    for (final route in _route.values) {
      await removeRoute(route);
    }
    removeEventListener(
        controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  void _zoomChangedEventHandler() {
    for (var route in _route.values) {
      _syncZoomLevel(
          route.id,
          route.multiple
              ? (route as MultipleRoute).styles
              : [(route as Route).style]);
    }
  }

  static int calculateZoomLevel(int zoomLevel) =>
      KakaoMapWebController.calculateZoomLevel(zoomLevel);

  void _syncZoomLevel(String routeId, List<RouteStyle> styles) {
    final mapZoomLevel = controller.getLevel();
    final webRoute = _webRoute[routeId]!;

    var currentStyles = styles;
    var currentZoomLevel = styles.map((e) => e.zoomLevel).toList();
    for (final (index, style) in styles.indexed) {
      for (final secondaryStyle in style._styles) {
        if (calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
            secondaryStyle.zoomLevel >= currentZoomLevel[index]) {
          currentZoomLevel[index] = secondaryStyle.zoomLevel;
          currentStyles[index] = secondaryStyle;
        }
      }
    }
    final points = webRoute.map((e) => e.bodyElement.getPath()).toList();

    for (final (index, routeElement) in webRoute.indexed) {
      if (_currentRouteLevel[routeId]![index] == currentZoomLevel[index]) {
        return;
      }
      routeElement.bodyElementOption.strokeColor =
          getColorCode(currentStyles[index].color);
      routeElement.bodyElementOption.strokeWeight =
          currentStyles[index].lineWidth * .5;
      routeElement.bodyElement.setOptions(routeElement.bodyElementOption);

      if (currentStyles[index].strokeWidth > 0) {
        final strokeElementOption = routeElement.strokeElementOption =
            _getStrokeElementOption(currentStyles[index], points[index], zOrder);
        if (routeElement.strokeElement == null) {
          routeElement.strokeElement = WebPolyline(strokeElementOption);
          routeElement.strokeElement?.setMap(controller);
        } else {
          routeElement.strokeElement?.setOptions(strokeElementOption);
        }
      } else {
        routeElement.strokeElement?.setMap(null);
        routeElement.strokeElement = null;
        routeElement.strokeElementOption = null;
      }
      if (currentStyles[index].pattern != null) {
        final patternElementOption = routeElement.patternElementOption =
            _getPatternElementOption(
                currentStyles[index], points[index], zOrder);
        if (routeElement.patternElement == null) {
          routeElement.patternElement = WebPolyline(patternElementOption);
          routeElement.patternElement?.setMap(controller);
        } else {
          routeElement.patternElement?.setOptions(patternElementOption);
        }
      } else {
        routeElement.patternElement?.setMap(null);
        routeElement.patternElement = null;
        routeElement.patternElementOption = null;
      }
      _currentRouteLevel[routeId]![index] = currentZoomLevel[index];
    }
  }

  @override
  Future<void> _changeMultipleRoute(
      String routeId, String styleId, List<RouteSegment> segments) async {
    final zOrder = _route[routeId]!.zOrder;
    final style = manager.getMultipleRotueStyle(styleId)!;

    for (final webRoute in _webRoute[routeId]!) {
      for (final routeElement in webRoute.allElement) {
        routeElement.setMap(null);
      }
    }
    _webRoute[routeId] = segments
        .map((segment) =>
            _addRouteElement(style[segment.styleIndex], segment.points, zOrder))
        .toList();
  }

  @override
  Future<void> _changeRoute(String routeId, String styleId, CurveType curveType,
      List<LatLng> points) async {
    final webRoute = _webRoute[routeId]![0];
    final zOrder = _route[routeId]!.zOrder;
    final style = manager.getRotueStyle(styleId)!;

    for (final routeElement in webRoute.allElement) {
      routeElement.setMap(null);
    }
    _webRoute[routeId] = [_addRouteElement(style, points, zOrder)];
  }

  @override
  Future<void> _changeRouteVisible(String routeId, bool visible) async {
    for (final route in _webRoute[routeId]!) {
      if (visible) {
        route.bodyElement.setMap(controller);
        route.strokeElement?.setMap(controller);
        route.patternElement?.setMap(controller);
      } else {
        route.bodyElement.setMap(null);
        route.strokeElement?.setMap(null);
        route.patternElement?.setMap(null);
      }
    }
  }

  WebPolylineOption _getBodyElementOption(
          RouteStyle style, JSArray<WebLatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points,
          strokeWeight: style.lineWidth * .5,
          strokeColor: getColorCode(style.color),
          strokeOpacity: 1,
          zIndex: zOrder);

  WebPolylineOption _getStrokeElementOption(
          RouteStyle style, JSArray<WebLatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points,
          strokeWeight: style.lineWidth * .5 + style.strokeWidth * .5,
          strokeColor: getColorCode(style.strokeColor),
          strokeOpacity: 1,
          zIndex: zOrder - 1);

  WebPolylineOption _getPatternElementOption(
          RouteStyle style, JSArray<WebLatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points,
          strokeWeight: 1,
          strokeColor: getColorCode(style.strokeColor),
          strokeOpacity: 1,
          strokeStyle: "longdash",
          zIndex: zOrder + 1);

  WebRoute _addRouteElement(RouteStyle style, List<LatLng> points, int zOrder) {
    final interopedPoints = points.map(WebLatLng.fromLatLng).toList().toJS;
    final bodyElementOption = _getBodyElementOption(style, interopedPoints, zOrder);
    final strokeElementOption = style.strokeWidth > 0
        ? _getStrokeElementOption(style, interopedPoints, zOrder)
        : null;
    final patternElementOption = style.pattern != null
        ? _getPatternElementOption(style, interopedPoints, zOrder)
        : null;

    final bodyElement = WebPolyline(bodyElementOption);
    final strokeElement =
        strokeElementOption != null ? WebPolyline(strokeElementOption) : null;
    final patternElement =
        patternElementOption != null ? WebPolyline(patternElementOption) : null;

    strokeElement?.setMap(controller);
    bodyElement.setMap(controller);
    patternElement?.setMap(controller);
    return WebRoute(bodyElement, strokeElement, patternElement,
        bodyElementOption, strokeElementOption, patternElementOption);
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
    _currentRouteLevel[routeId] = [style.zoomLevel];
    _syncZoomLevel(routeId, [style]);
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
    _webRoute[routeId] = option.segments
        .map((segment) =>
            _addRouteElement(segment.style, segment.points, option.zOrder))
        .toList();

    final route = MultipleRoute._(this, routeId,
        segments: option.segments,
        styles: option.styles,
        zOrder: option.zOrder);
    _route[routeId] = route;
    _currentRouteLevel[routeId] =
        option.styles.map((e) => e.zoomLevel).toList();
    _syncZoomLevel(routeId, option.styles);
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
