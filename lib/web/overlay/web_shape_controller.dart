part of '../../kakao_map_sdk.dart';

class WebShapeController extends ShapeController {
  final WebMapController controller;

  final Map<String, WebPolygon> _webPolygon = {};
  final Map<String, WebPolyline> _webPolyline = {};
  final Map<String, WebPolyline?> _webPolylineStroke = {};

  final Map<String, WebPolygonOption> _webPolygonOption = {};
  final Map<String, WebPolylineOption> _webPolylineOption = {};
  final Map<String, WebPolylineOption?> _webPolylineStrokeOption = {};

  final Map<String, int> _currentPolylineLevel = {};
  final Map<String, int> _currentPolygonLevel = {};

  WebShapeController._(this.controller, super.channel, super.manager, super.id)
      : super._();

  @override
  Future<void> _createShapeLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> _removeShapeLayer() async {
    removeEventListener(
        controller, "zoom_changed", _zoomChangedEventHandler.toJS);
    for (var shape in _polygonShape.values) {
      await removePolygonShape(shape);
    }
    for (var shape in _polylineShape.values) {
      await removePolylineShape(shape);
    }
  }

  void _zoomChangedEventHandler() {
    for (var shape in _polygonShape.values) {
      _syncPolygonZoomLevel(shape.id, shape.style);
    }
    for (var shape in _polylineShape.values) {
      _syncPolylineZoomLevel(shape.id, shape.style);
    }
  }

  static int calculateZoomLevel(int zoomLevel) =>
      KakaoMapWebController.calculateZoomLevel(zoomLevel);

  void _syncPolylineZoomLevel(String shapeId, PolylineStyle style) {
    final mapZoomLevel = controller.getLevel();
    final webPolyline = _webPolyline[shapeId]!;
    final webPolylineOption = _webPolylineOption[shapeId]!;

    var currentStyle = style;
    var currentZoomLevel = style.zoomLevel;
    for (final secondaryStyle in style._styles) {
      if (calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
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
      final strokeElement = _webPolylineStroke[shapeId] = WebPolyline(strokeOptions);
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
    for (final secondaryStyle in style._styles) {
      if (calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
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
  Future<void> _changePolylineVisible(String shapeId, bool visible) async {
    if (visible) {
      _webPolyline[shapeId]!.setMap(controller);
      _webPolylineStroke[shapeId]?.setMap(controller);
    } else {
      _webPolyline[shapeId]!.setMap(null);
      _webPolylineStroke[shapeId]?.setMap(null);
    }
  }

  @override
  Future<void> _changePolygonVisible(String shapeId, bool visible) async {
    if (visible) {
      _webPolygon[shapeId]!.setMap(controller);
    } else {
      _webPolygon[shapeId]!.setMap(null);
    }
  }

  @override
  Future<void> _changePolyline<T extends BasePoint>(
      String shapeId, T position, String styleId) async {
    final style = manager.getPolylineShapeStyle(styleId)!;
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
  Future<void> _changePolygon<T extends BasePoint>(
      String shapeId, T position, String styleId) async {
    final style = manager.getPolygonShapeStyle(styleId)!;
    final options = _webPolygonOption[shapeId]!;

    options.fillColor = _getColorCode(style.color);
    options.strokeColor = _getColorCode(style.strokeColor);
    options.strokeWeight = style.strokeWidth;

    _webPolygon[shapeId]?.setOptions(options);
    _webPolygonOption[shapeId] = options;
  }

  MapPoint _convertToMapPoint<T extends BasePoint>(T point) =>
      switch (point.type) {
        0 => point as MapPoint,
        1 => (() {
            final dotPoint = point as _BaseDotPoint;
            final absolutePoint = _getPointsFromDotPoint(dotPoint);
            final newPoint = MapPoint(absolutePoint);

            dotPoint._holes
                .map(
                    (hole) => _getPointsFromDotPoint(hole, dotPoint.basePoint!))
                .forEach(newPoint.addHole);
            return newPoint;
          })(),
        int() => throw UnimplementedError(),
      };

  List<LatLng> _getPointsFromDotPoint<T extends _BaseDotPoint>(T point,
      [LatLng? basePoint]) {
    final absolutePoint = <LatLng>[];
    final basePoint0 = basePoint ?? point.basePoint!;

    if (point is CirclePoint) {
      for (int degrees = 0; degrees < 360; degrees++) {
        absolutePoint.add(basePoint0.offset(point.radius, degrees.toDouble()));
      }
    }

    if (point is RectanglePoint) {
      absolutePoint.addAll([
        basePoint0.offset(-point.width * .5, 90).offset(point.height * .5, 0),
        basePoint0.offset(point.height * .5, 0).offset(point.width * .5, 90),
        basePoint0.offset(point.width * .5, 90).offset(-point.height * .5, 0),
        basePoint0.offset(-point.height * .5, 0).offset(-point.width * .5, 90),
        basePoint0.offset(-point.width * .5, 90).offset(point.height * .5, 0),
      ]);
    }
    return absolutePoint;
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
  Future<Polyline> addPolylineShape<T extends BasePoint>(
      T position, PolylineStyle style, PolylineCap polylineCap,
      {String? id, int zOrder = 10001}) async {
    style._id ?? await manager.addPolylineShapeStyle(style, polylineCap);
    if (id != null && _polygonShape.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final point = _convertToMapPoint(position);
    final shapeId = "polyline_shape_${id}_${_polylineShape.length}";

    final polylineOption = _webPolylineOption[shapeId] =
        _getPolylineElementOption(style,
            point.points.map(WebLatLng.fromLatLng).toList().toJS, zOrder);
    _webPolyline[shapeId] = WebPolyline(polylineOption);
    _webPolyline[shapeId]!.setMap(controller);

    if (style.strokeWidth > 0) {
      final polylineStrokeOption = _webPolylineStrokeOption[shapeId] =
          _getPolylineStrokeElementOption(style,
              point.points.map(WebLatLng.fromLatLng).toList().toJS, zOrder);
      _webPolylineStroke[shapeId] = WebPolyline(polylineStrokeOption);
      _webPolylineStroke[shapeId]!.setMap(controller);
    }

    final polyline = Polyline<T>._(this, shapeId,
        position: position, style: style, polylineCap: polylineCap);
    _polylineShape[shapeId] = polyline;
    _syncPolylineZoomLevel(polyline.id, polyline.style);
    return polyline;
  }

  @override
  Future<Polygon> addPolygonShape<T extends BasePoint>(
      T position, PolygonStyle style,
      {String? id, int zOrder = 10001}) async {
    if (id != null && _polygonShape.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final point = _convertToMapPoint(position);
    style._id ?? await manager.addPolygonShapeStyle(style);
    final shapeId = "polygon_shape_${id}_${_polygonShape.length}";

    final path = <JSArray<WebLatLng>>[];
    path.add(point.points.map(WebLatLng.fromLatLng).toList().toJS);
    point._holes
        .map((hole) => hole.map(WebLatLng.fromLatLng).toList().toJS)
        .forEach(path.add);

    final polygonOption = _webPolygonOption[shapeId] =
        _getPolygonElementOption(style, path.toJS, zOrder);
    _webPolygon[shapeId] = WebPolygon(polygonOption);
    _webPolygon[shapeId]!.setMap(controller);

    final polygon =
        Polygon<T>._(this, shapeId, position: position, style: style);
    _polygonShape[shapeId] = polygon;
    _syncPolygonZoomLevel(polygon.id, polygon.style);
    return polygon;
  }

  @override
  Future<void> removePolylineShape(Polyline shape) async {
    _webPolyline[shape.id]!.setMap(null);
    _webPolylineStroke[shape.id]?.setMap(null);

    _polylineShape.remove(shape.id);
    _webPolyline.remove(shape.id);
    _webPolylineStroke.remove(shape.id);
  }

  @override
  Future<void> removePolygonShape(Polygon shape) async {
    _webPolygon[shape.id]!.setMap(null);

    _polygonShape.remove(shape.id);
    _webPolygon.remove(shape.id);
  }

  @override
  Future<void> showAllPolyline() async {
    for (var shape in _polylineShape.values) {
      await shape.show();
    }
  }

  @override
  Future<void> hideAllPolyline() async {
    for (var shape in _polylineShape.values) {
      await shape.hide();
    }
  }

  @override
  Future<void> showAllPolygon() async {
    for (var shape in _polygonShape.values) {
      await shape.show();
    }
  }

  @override
  Future<void> hideAllPolygon() async {
    for (var shape in _polygonShape.values) {
      await shape.hide();
    }
  }
}
