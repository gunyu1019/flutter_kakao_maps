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
  Future<void> _createShapeLayer() async {}

  @override
  Future<void> _removeShapeLayer() async {
    for (var shape in _polygonShape.values) {
      await removePolygonShape(shape);
    }
    for (var shape in _polylineShape.values) {
      await removePolylineShape(shape);
    }
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

    strokeOptions?.strokeColor = getColorCode(style.strokeColor);
    bodyOptions.strokeColor = getColorCode(style.color);
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

    options.fillColor = getColorCode(style.color);
    options.strokeColor = getColorCode(style.strokeColor);
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
          PolylineStyle style, List<LatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points.map(WebLatLng.fromLatLng).toList().toJS,
          strokeWeight: style.lineWidth * .5,
          strokeColor: getColorCode(style.color),
          strokeOpacity: 1,
          zIndex: zOrder);

  WebPolylineOption _getPolylineStrokeElementOption(
          PolylineStyle style, List<LatLng> points, int zOrder) =>
      WebPolylineOption(
          path: points.map(WebLatLng.fromLatLng).toList().toJS,
          strokeWeight: style.lineWidth * .5 + style.strokeWidth * .5,
          strokeColor: getColorCode(style.strokeColor),
          strokeOpacity: 1,
          zIndex: zOrder - 1);

  WebPolygonOption _getPolygonElementOption(PolygonStyle style,
      List<LatLng> points, List<List<LatLng>> holes, int zOrder) {
    final path = <JSArray<WebLatLng>>[];
    path.add(points.map(WebLatLng.fromLatLng).toList().toJS);
    holes
        .map((hole) => hole.map(WebLatLng.fromLatLng).toList().toJS)
        .forEach(path.add);

    return WebPolygonOption(
        path: path.toJS,
        fillColor: getColorCode(style.color),
        fillOpacity: 1,
        strokeWeight: style.strokeWidth,
        strokeColor: getColorCode(style.strokeColor),
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
        _getPolylineElementOption(style, point.points, zOrder);
    _webPolyline[shapeId] = WebPolyline(polylineOption);
    _webPolyline[shapeId]!.setMap(controller);

    if (style.strokeWidth > 0) {
      final polylineStrokeOption = _webPolylineStrokeOption[shapeId] =
          _getPolylineStrokeElementOption(style, point.points, zOrder);
      _webPolylineStroke[shapeId] = WebPolyline(polylineStrokeOption);
      _webPolylineStroke[shapeId]!.setMap(controller);
    }

    final polyline = Polyline<T>._(this, shapeId,
        position: position, style: style, polylineCap: polylineCap);
    _polylineShape[shapeId] = polyline;
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

    final polygonOption = _webPolygonOption[shapeId] =
        _getPolygonElementOption(style, point.points, point._holes, zOrder);
    _webPolygon[shapeId] = WebPolygon(polygonOption);
    _webPolygon[shapeId]!.setMap(controller);

    final polygon =
        Polygon<T>._(this, shapeId, position: position, style: style);
    _polygonShape[shapeId] = polygon;
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
