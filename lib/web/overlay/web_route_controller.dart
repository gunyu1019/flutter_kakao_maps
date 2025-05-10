part of '../kakao_map_sdk_web.dart';

class WebRouteController with WebRouteControllerHandler {
  final String id;
  final WebMapController controller;

  final Map<String, List<WebRoute>> _webRoute = {};
  final Map<String, List<int>> _currentRouteLevel = {};

  final Map<String, String> _routeStyleId = {};
  final Map<String, List<int>> _routeStyleIndex = {};
  final Map<String, int> _routeZOrder = {};

  @override
  final WebOverlayController manager;

  WebRouteController._(this.id, this.controller, this.manager);

  @override
  Future<void> createRouteLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> removeRouteLayer() async {
    for (final route in _webRoute.keys) {
      await removeRoute(route);
    }
    removeEventListener(
        controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  void _zoomChangedEventHandler() {
    for (final route in _webRoute.keys) {
      final styles = manager._routeStyles[_routeStyleId[route]!]!;
      _syncZoomLevel(route, styles);
    }
  }

  void _syncZoomLevel(String routeId, List<RouteStyle> styles) {
    final mapZoomLevel = controller.getLevel();
    final webRoute = _webRoute[routeId]!;
    final zOrder = _routeZOrder[routeId]!;

    var currentStyles = styles;
    var currentZoomLevel = styles.map((e) => e.zoomLevel).toList();
    for (final (index, style) in styles.indexed) {
      for (final secondaryStyle in style.otherStyles) {
        if (_calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
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
          _getColorCode(currentStyles[index].color);
      routeElement.bodyElementOption.strokeWeight =
          currentStyles[index].lineWidth * .5;
      routeElement.bodyElement.setOptions(routeElement.bodyElementOption);

      if (currentStyles[index].strokeWidth > 0) {
        final strokeElementOption = routeElement.strokeElementOption =
            _getStrokeElementOption(
                currentStyles[index], points[index], zOrder);
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
  Future<void> changeRoute(
      String routeId, String styleId, List<List<LatLng>> points) async {
    final zOrder = _routeZOrder[routeId]!;
    final styleIndex = _routeStyleIndex[routeId]!;
    final styles = manager._routeStyles[styleId]!;

    for (final webRoute in _webRoute[routeId]!) {
      for (final routeElement in webRoute.allElement) {
        routeElement.setMap(null);
      }
    }
    _webRoute[routeId] = points
        .mapIndexed((index, point) => _addRouteElement(
            styles.elementAtOrNull(styleIndex.elementAtOrNull(index) ?? 0) ??
                styles[0],
            point,
            zOrder))
        .toList();
  }

  @override
  Future<void> changeRouteZOrder(String routeId, int zOrder) async {
    for (final webRoute in _webRoute[routeId]!) {
      webRoute.bodyElement.setZIndex(zOrder);
      webRoute.strokeElement?.setZIndex(zOrder - 1);
      webRoute.patternElement?.setZIndex(zOrder + 1);
    }
  }

  @override
  Future<void> changeRouteVisible(String routeId, bool visible) async {
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
          strokeColor: _getColorCode(style.color),
          strokeOpacity: 1,
          zIndex: zOrder);

  WebPolylineOption _getStrokeElementOption(
          RouteStyle style, JSArray<WebLatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points,
          strokeWeight: style.lineWidth * .5 + style.strokeWidth * .5,
          strokeColor: _getColorCode(style.strokeColor),
          strokeOpacity: 1,
          zIndex: zOrder - 1);

  WebPolylineOption _getPatternElementOption(
          RouteStyle style, JSArray<WebLatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points,
          strokeWeight: 1,
          strokeColor: _getColorCode(style.strokeColor),
          strokeOpacity: 1,
          strokeStyle: "longdash",
          zIndex: zOrder + 1);

  WebRoute _addRouteElement(RouteStyle style, List<LatLng> points, int zOrder) {
    final interopedPoints = points.map(WebLatLng.fromLatLng).toList().toJS;
    final bodyElementOption =
        _getBodyElementOption(style, interopedPoints, zOrder);
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
  Future<String> addRoute(List<LatLng> points, RouteStyle style,
      {String? id,
      CurveType curveType = CurveType.none,
      int zOrder = 10000}) async {
    String routeId = manager._uuid.v4();
    _webRoute[routeId] = [_addRouteElement(style, points, zOrder)];
    _routeStyleId[routeId] = style.id!;
    _routeZOrder[routeId] = zOrder;
    _routeStyleIndex[routeId] = [0];

    _currentRouteLevel[routeId] = [style.zoomLevel];
    _syncZoomLevel(routeId, [style]);
    return routeId;
  }

  @override
  Future<String> addMultipleRoute(MultipleRouteOption option) async {
    String routeId = manager._uuid.v4();
    _webRoute[routeId] = option.segments
        .map((segment) =>
            _addRouteElement(segment.style, segment.points, option.zOrder))
        .toList();

    _currentRouteLevel[routeId] =
        option.styles.map((e) => e.zoomLevel).toList();
    _routeStyleId[routeId] = option.styles[0].id!;
    _routeZOrder[routeId] = option.zOrder;
    _routeStyleIndex[routeId] =
        option.segments.map((e) => e.styleIndex).toList();
    _syncZoomLevel(routeId, option.styles);
    return routeId;
  }

  @override
  Future<void> removeRoute(String routeId) async {
    await changeRouteVisible(routeId, false);
    _webRoute.remove(routeId);
  }

  @override
  Future<void> showAllRoute() async {
    for (var route in _webRoute.keys) {
      await changeRouteVisible(route, true);
    }
  }

  @override
  Future<void> hideAllRoute() async {
    for (var route in _webRoute.keys) {
      await changeRouteVisible(route, false);
    }
  }
}
