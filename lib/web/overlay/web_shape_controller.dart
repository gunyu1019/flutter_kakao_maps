part of '../kakao_map_sdk_web.dart';

class WebShapeController with WebShapeControllerHandler {
  final String id;
  final WebMapController controller;

  final Map<String, WebPolygonShape> _webPolygon = {};
  final Map<String, WebPolylineShape> _webPolyline = {};

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
      controller,
      "zoom_changed",
      _zoomChangedEventHandler.toJS,
    );
    for (var shape in _webPolygon.keys) {
      await removePolygonShape(shape);
    }
    for (var shape in _webPolyline.keys) {
      await removePolylineShape(shape);
    }
  }

  void _zoomChangedEventHandler() {
    for (var shape in _webPolygon.values) {
      _syncPolygonZoomLevel(shape.id, shape.style);
    }
    for (var shape in _webPolyline.values) {
      _syncPolylineZoomLevel(shape.id, shape.style);
    }
  }

  void _syncPolylineZoomLevel(String shapeId, PolylineStyle style) {
    final mapZoomLevel = controller.getLevel();
    final webPolyline = _webPolyline[shapeId]!;

    var currentStyle = style;
    var currentZoomLevel = style.zoomLevel;
    for (final secondaryStyle in style.otherStyles) {
      if (_calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
          secondaryStyle.zoomLevel >= currentZoomLevel) {
        currentZoomLevel = secondaryStyle.zoomLevel;
        currentStyle = secondaryStyle;
      }
    }

    if (webPolyline.currentLevel == currentZoomLevel) return;
    _webPolyline[shapeId]!.currentLevel = currentZoomLevel;
    if (currentStyle.strokeWidth > 0) {
      final strokeOptions =
          _webPolyline[shapeId]!.strokeOption = _getPolylineStrokeElementOption(
        currentStyle,
        webPolyline.option.path,
        webPolyline.element.getZIndex() - 1,
      );
      final strokeElement = _webPolyline[shapeId]!.strokeElement = WebPolyline(
        strokeOptions,
      );
      strokeElement.setMap(controller);
    } else {
      webPolyline.strokeElement?.setMap(null);
      _webPolyline[shapeId]?.strokeElement = null;
      _webPolyline[shapeId]?.strokeOption = null;
    }

    _webPolyline[shapeId]!.option.strokeColor = _getColorCode(
      currentStyle.color,
    );
    _webPolyline[shapeId]!.option.strokeWeight = currentStyle.lineWidth * .5;
    _webPolyline[shapeId]!.element.setOptions(_webPolyline[shapeId]!.option);
  }

  void _syncPolygonZoomLevel(String shapeId, PolygonStyle style) {
    final mapZoomLevel = controller.getLevel();
    final webPolygon = _webPolygon[shapeId]!;

    var currentStyle = style;
    var currentZoomLevel = style.zoomLevel;
    for (final secondaryStyle in style.otherStyles) {
      if (_calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
          secondaryStyle.zoomLevel >= currentZoomLevel) {
        currentZoomLevel = secondaryStyle.zoomLevel;
        currentStyle = secondaryStyle;
      }
    }

    if (webPolygon.currentLevel == currentZoomLevel) return;
    _webPolygon[shapeId]!.currentLevel = currentZoomLevel;

    _webPolygon[shapeId]!.option.fillColor = _getColorCode(currentStyle.color);
    _webPolygon[shapeId]!.option.strokeColor = _getColorCode(
      currentStyle.strokeColor,
    );
    _webPolygon[shapeId]!.option.strokeWeight = currentStyle.strokeWidth;
    _webPolygon[shapeId]!.element.setOptions(_webPolygon[shapeId]!.option);
  }

  @override
  Future<void> changePolylineVisible(String shapeId, bool visible) async {
    if (visible) {
      _webPolyline[shapeId]!.element.setMap(controller);
      _webPolyline[shapeId]?.element.setMap(controller);
    } else {
      _webPolyline[shapeId]!.element.setMap(null);
      _webPolyline[shapeId]?.element.setMap(null);
    }
  }

  @override
  Future<void> changePolygonVisible(String shapeId, bool visible) async {
    if (visible) {
      _webPolygon[shapeId]!.element.setMap(controller);
    } else {
      _webPolygon[shapeId]!.element.setMap(null);
    }
  }

  @override
  Future<void> changePolyline(
    String shapeId,
    WebShapePoint point,
    String styleId,
  ) async {
    final style = manager._polylineStyles[styleId]![0];
    final bodyOptions = _webPolyline[shapeId]!.option;
    final strokeOptions = _webPolyline[shapeId]!.strokeOption;

    strokeOptions?.strokeColor = _getColorCode(style.strokeColor);
    bodyOptions.strokeColor = _getColorCode(style.color);
    strokeOptions?.strokeWeight = style.lineWidth * .5 + style.strokeWidth * .5;
    bodyOptions.strokeWeight = style.lineWidth * .5;

    _webPolyline[shapeId]!.element.setOptions(bodyOptions);
    _webPolyline[shapeId]!.strokeElement?.setOptions(strokeOptions!);
    _webPolyline[shapeId]!.option = bodyOptions;
    _webPolyline[shapeId]!.strokeOption = strokeOptions;
  }

  @override
  Future<void> changePolygon(
    String shapeId,
    WebShapePoint point,
    String styleId,
  ) async {
    final style = manager._polygonStyles[styleId]![0];
    final options = _webPolygon[shapeId]!.option;

    options.fillColor = _getColorCode(style.color);
    options.strokeColor = _getColorCode(style.strokeColor);
    options.strokeWeight = style.strokeWidth;

    _webPolygon[shapeId]!.element.setOptions(options);
    _webPolygon[shapeId]!.option = options;
  }

  WebPolylineOption _getPolylineElementOption(
    PolylineStyle style,
    JSArray<WebLatLng> points,
    int zOrder,
  ) =>
      WebPolylineOption(
        path: points,
        strokeWeight: style.lineWidth * .5,
        strokeColor: _getColorCode(style.color),
        strokeOpacity: 1,
        zIndex: zOrder,
      );

  WebPolylineOption _getPolylineStrokeElementOption(
    PolylineStyle style,
    JSArray<WebLatLng> points,
    int zOrder,
  ) =>
      WebPolylineOption(
        path: points,
        strokeWeight: style.lineWidth * .5 + style.strokeWidth * .5,
        strokeColor: _getColorCode(style.strokeColor),
        strokeOpacity: 1,
        zIndex: zOrder - 1,
      );

  WebPolygonOption _getPolygonElementOption(
    PolygonStyle style,
    JSArray<JSArray<WebLatLng>> path,
    int zOrder,
  ) {
    return WebPolygonOption(
      path: path,
      fillColor: _getColorCode(style.color),
      fillOpacity: 1,
      strokeWeight: style.strokeWidth,
      strokeColor: _getColorCode(style.strokeColor),
      strokeOpacity: 1,
      zIndex: zOrder,
    );
  }

  @override
  Future<String> addPolylineShape(
    WebShapePoint point,
    PolylineStyle style, {
    String? id,
    int zOrder = 10001,
  }) async {
    final shapeId = id ?? manager._uuid.v4();
    final path = point.toPolylinePath();

    final polylineOption = _getPolylineElementOption(style, path, zOrder);
    final polyline = WebPolyline(polylineOption);
    polyline.setMap(controller);

    WebPolylineOption? polylineStrokeOption;
    WebPolyline? polylineStroke;

    if (style.strokeWidth > 0) {
      polylineStrokeOption = _getPolylineStrokeElementOption(
        style,
        path,
        zOrder,
      );
      polylineStroke = WebPolyline(polylineStrokeOption);
      polylineStroke.setMap(controller);
    }

    _webPolyline[shapeId] = WebPolylineShape(
      shapeId,
      polyline,
      polylineStroke,
      option: polylineOption,
      strokeOption: polylineStrokeOption,
      style: style,
    );
    _syncPolylineZoomLevel(shapeId, style);
    return shapeId;
  }

  @override
  Future<String> addPolygonShape(
    WebShapePoint point,
    PolygonStyle style, {
    String? id,
    int zOrder = 10001,
  }) async {
    final shapeId = id ?? manager._uuid.v4();

    final polygonOption = _getPolygonElementOption(
      style,
      point.toPolygonPath(),
      zOrder,
    );
    final polygon = WebPolygon(polygonOption);
    polygon.setMap(controller);

    _webPolygon[shapeId] = WebPolygonShape(
      shapeId,
      polygon,
      option: polygonOption,
      style: style,
    );
    _syncPolygonZoomLevel(shapeId, style);
    return shapeId;
  }

  @override
  Future<void> removePolylineShape(String shapeId) async {
    _webPolyline[shapeId]!.element.setMap(null);
    _webPolyline[shapeId]!.strokeElement?.setMap(null);
    _webPolyline.remove(shapeId);
  }

  @override
  Future<void> removePolygonShape(String shapeId) async {
    _webPolygon[shapeId]!.element.setMap(null);
    _webPolygon.remove(shapeId);
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
