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
  Future<void> _removeShapeLayer() async {}

  @override
  Future<void> _changePolylineVisible(String shapeId, bool visible) async {}

  @override
  Future<void> _changePolygonVisible(String shapeId, bool visible) async {}

  @override
  Future<void> _changePolyline<T extends BasePoint>(
      String shapeId, T position, String styleId) async {}

  @override
  Future<void> _changePolygon<T extends BasePoint>(
      String shapeId, T position, String styleId) async {}

  // ignore: library_private_types_in_public_api
  MapPoint convertToMapPoint<T extends _BaseDotPoint>(T point) =>
      throw UnimplementedError();

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
    final point = position as MapPoint;
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
    final point = position as MapPoint;
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
    _polylineShape.remove(shape.id);
    _webPolyline.remove(shape.id);
    _webPolylineStroke.remove(shape.id);
  }

  @override
  Future<void> removePolygonShape(Polygon shape) async {
    _polygonShape.remove(shape.id);
    _webPolygon.remove(shape.id);
  }

  @override
  Future<void> showAllPolyline() async {}

  @override
  Future<void> hideAllPolyline() async {}

  @override
  Future<void> showAllPolygon() async {}

  @override
  Future<void> hideAllPolygon() async {}
}
