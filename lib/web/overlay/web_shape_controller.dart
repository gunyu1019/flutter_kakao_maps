part of '../kakao_map_sdk_web.dart';

class WebShapeController with WebShapeControllerHandler {
  final String id;
  final WebMapController controller;

  final Map<String, WebPolygon> _webPolygon = {};
  final Map<String, WebPolyline> _webPolyline = {};
  final Map<String, WebPolyline?> _webPolylineStroke = {};

  final Map<String, WebPolygonOption> _webPolygonOption = {};
  final Map<String, WebPolylineOption> _webPolylineOption = {};
  final Map<String, WebPolylineOption?> _webPolylineStrokeOption = {};

  final Map<String, int> _currentPolylineLevel = {};
  final Map<String, int> _currentPolygonLevel = {};

  final Map<String, PolylineStyle> _polylineStyle = {};
  final Map<String, PolygonStyle> _polygonStyle = {};

  @override
  final WebOverlayController manager;

  WebShapeController._(this.id, this.controller, this.manager);

  @override
  Future<void> createShapeLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> removeShapeLayer() async {
    removeEventListener(
        controller, "zoom_changed", _zoomChangedEventHandler.toJS);
    for (var shape in _webPolygon.keys) {
      await removePolygonShape(shape);
    }
    for (var shape in _webPolyline.keys) {
      await removePolylineShape(shape);
    }
  }

  void _zoomChangedEventHandler() {
    for (var shape in _webPolygon.keys) {
      final style = _polygonStyle[shape]!;
      _syncPolygonZoomLevel(shape, style);
    }
    for (var shape in _webPolyline.keys) {
      final style = _polylineStyle[shape]!;
      _syncPolylineZoomLevel(shape, style);
    }
  }

  void _syncPolylineZoomLevel(String shapeId, PolylineStyle style) {
    final mapZoomLevel = controller.getLevel();
    final webPolyline = _webPolyline[shapeId]!;
    final webPolylineOption = _webPolylineOption[shapeId]!;

    var currentStyle = style;
    var currentZoomLevel = style.zoomLevel;
    for (final secondaryStyle in style.otherStyles) {
      if (_calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
          secondaryStyle.zoomLevel >= currentZoomLevel) {
        currentZoomLevel = secondaryStyle.zoomLevel;
        currentStyle = secondaryStyle;
      }
    }

    if (_currentPolylineLevel[shapeId] == currentZoomLevel) return;
    _currentPolylineLevel[shapeId] = currentZoomLevel;
    if (currentStyle.strokeWidth > 0) {
      final strokeOptions = _webPolylineStrokeOption[shapeId] =
          _getPolylineStrokeElementOption(currentStyle, webPolylineOption.path,
              webPolyline.getZIndex() - 1);
      final strokeElement =
          _webPolylineStroke[shapeId] = WebPolyline(strokeOptions);
      strokeElement.setMap(controller);
    } else {
      _webPolylineStroke[shapeId]?.setMap(null);
      _webPolylineStroke[shapeId] = null;
      _webPolylineStrokeOption[shapeId] = null;
    }

    webPolylineOption.strokeColor = _getColorCode(currentStyle.color);
    webPolylineOption.strokeWeight = currentStyle.lineWidth * .5;
    _webPolyline[shapeId]!.setOptions(webPolylineOption);
  }

  void _syncPolygonZoomLevel(String shapeId, PolygonStyle style) {
    final mapZoomLevel = controller.getLevel();
    final webPolygonOption = _webPolygonOption[shapeId]!;

    var currentStyle = style;
    var currentZoomLevel = style.zoomLevel;
    for (final secondaryStyle in style.otherStyles) {
      if (_calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
          secondaryStyle.zoomLevel >= currentZoomLevel) {
        currentZoomLevel = secondaryStyle.zoomLevel;
        currentStyle = secondaryStyle;
      }
    }

    if (_currentPolygonLevel[shapeId] == currentZoomLevel) return;
    _currentPolygonLevel[shapeId] = currentZoomLevel;

    webPolygonOption.fillColor = _getColorCode(currentStyle.color);
    webPolygonOption.strokeColor = _getColorCode(currentStyle.strokeColor);
    webPolygonOption.strokeWeight = currentStyle.strokeWidth;
    _webPolygon[shapeId]!.setOptions(webPolygonOption);
  }

  @override
  Future<void> changePolylineVisible(String shapeId, bool visible) async {
    if (visible) {
      _webPolyline[shapeId]!.setMap(controller);
      _webPolylineStroke[shapeId]?.setMap(controller);
    } else {
      _webPolyline[shapeId]!.setMap(null);
      _webPolylineStroke[shapeId]?.setMap(null);
    }
  }

  @override
  Future<void> changePolygonVisible(String shapeId, bool visible) async {
    if (visible) {
      _webPolygon[shapeId]!.setMap(controller);
    } else {
      _webPolygon[shapeId]!.setMap(null);
    }
  }

  @override
  Future<void> changePolyline(
      String shapeId, WebShapePoint point, String styleId) async {
    final style = manager._polylineStyles[styleId]![0];
    final bodyOptions = _webPolylineOption[shapeId]!;
    final strokeOptions = _webPolylineStrokeOption[shapeId];

    strokeOptions?.strokeColor = _getColorCode(style.strokeColor);
    bodyOptions.strokeColor = _getColorCode(style.color);
    strokeOptions?.strokeWeight = style.lineWidth * .5 + style.strokeWidth * .5;
    bodyOptions.strokeWeight = style.lineWidth * .5;

    _webPolyline[shapeId]?.setOptions(bodyOptions);
    _webPolylineStroke[shapeId]?.setOptions(strokeOptions!);
    _webPolylineOption[shapeId] = bodyOptions;
    _webPolylineStrokeOption[shapeId] = strokeOptions;
  }

  @override
  Future<void> changePolygon(
      String shapeId, WebShapePoint point, String styleId) async {
    final style = manager._polygonStyles[styleId]![0];
    final options = _webPolygonOption[shapeId]!;

    options.fillColor = _getColorCode(style.color);
    options.strokeColor = _getColorCode(style.strokeColor);
    options.strokeWeight = style.strokeWidth;

    _webPolygon[shapeId]?.setOptions(options);
    _webPolygonOption[shapeId] = options;
  }

  WebPolylineOption _getPolylineElementOption(
          PolylineStyle style, JSArray<WebLatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points,
          strokeWeight: style.lineWidth * .5,
          strokeColor: _getColorCode(style.color),
          strokeOpacity: 1,
          zIndex: zOrder);

  WebPolylineOption _getPolylineStrokeElementOption(
          PolylineStyle style, JSArray<WebLatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points,
          strokeWeight: style.lineWidth * .5 + style.strokeWidth * .5,
          strokeColor: _getColorCode(style.strokeColor),
          strokeOpacity: 1,
          zIndex: zOrder - 1);

  WebPolygonOption _getPolygonElementOption(
      PolygonStyle style, JSArray<JSArray<WebLatLng>> path, int zOrder) {
    return WebPolygonOption(
        path: path,
        fillColor: _getColorCode(style.color),
        fillOpacity: 1,
        strokeWeight: style.strokeWidth,
        strokeColor: _getColorCode(style.strokeColor),
        strokeOpacity: 1,
        zIndex: zOrder);
  }

  @override
  Future<String> addPolylineShape(WebShapePoint point, PolylineStyle style,
      {String? id, int zOrder = 10001}) async {
    final shapeId = manager._uuid.v4();
    final path = point.toPolylinePath();

    final polylineOption = _webPolylineOption[shapeId] =
        _getPolylineElementOption(style, path, zOrder);
    _webPolyline[shapeId] = WebPolyline(polylineOption);
    _webPolyline[shapeId]!.setMap(controller);

    if (style.strokeWidth > 0) {
      final polylineStrokeOption = _webPolylineStrokeOption[shapeId] =
          _getPolylineStrokeElementOption(style, path, zOrder);
      _webPolylineStroke[shapeId] = WebPolyline(polylineStrokeOption);
      _webPolylineStroke[shapeId]!.setMap(controller);
    }

    _polylineStyle[shapeId] = style;
    _currentPolylineLevel[shapeId] = style.zoomLevel;
    _syncPolylineZoomLevel(shapeId, style);
    return shapeId;
  }

  @override
  Future<String> addPolygonShape(WebShapePoint point, PolygonStyle style,
      {String? id, int zOrder = 10001}) async {
    final shapeId = manager._uuid.v4();

    final polygonOption = _webPolygonOption[shapeId] =
        _getPolygonElementOption(style, point.toPolygonPath(), zOrder);
    _webPolygon[shapeId] = WebPolygon(polygonOption);
    _webPolygon[shapeId]!.setMap(controller);

    _polygonStyle[shapeId] = style;
    _currentPolylineLevel[shapeId] = style.zoomLevel;
    _syncPolygonZoomLevel(shapeId, style);
    return shapeId;
  }

  @override
  Future<void> removePolylineShape(String shapeId) async {
    _webPolyline[shapeId]!.setMap(null);
    _webPolylineStroke[shapeId]?.setMap(null);

    _webPolyline.remove(shapeId);
    _webPolylineStroke.remove(shapeId);
    _currentPolylineLevel.remove(shapeId);
    _webPolylineOption.remove(shapeId);
    _webPolylineStrokeOption.remove(shapeId);
    _polylineStyle.remove(shapeId);
  }

  @override
  Future<void> removePolygonShape(String shapeId) async {
    _webPolygon[shapeId]!.setMap(null);

    _webPolygon.remove(shapeId);
    _currentPolygonLevel.remove(shapeId);
    _webPolygonOption.remove(shapeId);
    _polygonStyle.remove(shapeId);
  }

  @override
  Future<void> showAllPolyline() async {
    for (var shape in _webPolyline.keys) {
      await changePolylineVisible(shape, true);
    }
  }

  @override
  Future<void> hideAllPolyline() async {
    for (var shape in _webPolyline.keys) {
      await changePolylineVisible(shape, false);
    }
  }

  @override
  Future<void> showAllPolygon() async {
    for (var shape in _webPolyline.keys) {
      await changePolygonVisible(shape, true);
    }
  }

  @override
  Future<void> hideAllPolygon() async {
    for (var shape in _webPolyline.keys) {
      await changePolygonVisible(shape, false);
    }
  }
}
