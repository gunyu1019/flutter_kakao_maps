part of '../../kakao_map_sdk.dart';

class ShapeController extends OverlayController {
  @override
  MethodChannel channel;

  @override
  OverlayManager manager;

  @override
  OverlayType get type => OverlayType.shape;

  final String id;
  final ShapeLayerPass passType;
  final int zOrder;

  final Map<String, Polyline> _polylineShape = {};
  final Map<String, Polygon> _polygonShape = {};

  ShapeController._(this.channel, this.manager, this.id,
      {this.passType = defaultShapeLayerPass, this.zOrder = defaultZOrder});

  Future<void> _createShapeLayer() async {
    await _invokeMethod(
        "createShapeLayer", {"passType": passType.value, "zOrder": zOrder});
  }

  Future<void> _removeShapeLayer() async {
    await _invokeMethod("removeShapeLayer", {});
  }

  Future<void> _changePolylineVisible(String shapeId, bool visible) async {
    await _invokeMethod(
        "changePolylineVisible", {"shapeId": shapeId, "visible": visible});
  }

  Future<void> _changePolygonVisible(String shapeId, bool visible) async {
    await _invokeMethod(
        "changePolygonVisible", {"shapeId": shapeId, "visible": visible});
  }

  Future<void> _changePolylineStyle(String shapeId, String styleId) async {
    await _invokeMethod(
        "changePolylineStyle", {"shapeId": shapeId, "styleId": styleId});
  }

  Future<void> _changePolygonStyle(String shapeId, String styleId) async {
    await _invokeMethod(
        "changePolygonStyle", {"shapeId": shapeId, "styleId": styleId});
  }

  Future<void> _changePolylinePosition<T extends BasePoint>(
      String shapeId, T position) async {
    await _invokeMethod("changePolylinePosition",
        {"shapeId": shapeId, "position": position.toMessageable()});
  }

  Future<void> _changePolygonPosition<T extends BasePoint>(
      String shapeId, T position) async {
    await _invokeMethod("changePolygonPosition",
        {"shapeId": shapeId, "position": position.toMessageable()});
  }

  @override
  Future<T> _invokeMethod<T>(String method, Map<String, dynamic> payload) {
    payload['layerId'] = id;
    return super._invokeMethod(method, payload);
  }

  Future<Polyline> addPolylineShape<T extends BasePoint>(
      T position, PolylineStyle style, PolylineCap polylineCap,
      {String? id, int zOrder = 10001}) async {
    final styleId =
        style._id ?? await manager.addPolylineShapeStyle(style, polylineCap);
    final payload = <String, dynamic>{
      "polyline": <String, dynamic>{
        "id": id,
        "position": position.toMessageable(),
        "styleId": styleId,
        "zOrder": zOrder
      }
    };
    String shapeId = await _invokeMethod("addPolylineShape", payload);
    final polyline = Polyline<T>._(this, shapeId,
        position: position, style: style, polylineCap: polylineCap);
    _polylineShape[shapeId] = polyline;
    return polyline;
  }

  Future<Polygon> addPolygonShape<T extends BasePoint>(
      T position, PolygonStyle style,
      {String? id, int zOrder = 10001}) async {
    final styleId = style._id ?? await manager.addPolygonShapeStyle(style);
    final payload = <String, dynamic>{
      "polygon": <String, dynamic>{
        "id": id,
        "position": position.toMessageable(),
        "styleId": styleId,
        "zOrder": zOrder
      }
    };
    String shapeId = await _invokeMethod("addPolygonShape", payload);
    final polygon =
        Polygon<T>._(this, shapeId, position: position, style: style);
    _polygonShape[shapeId] = polygon;
    return polygon;
  }

  Polyline? getPolylineShape(String id) => _polylineShape[id];

  Polygon? getPolygonShape(String id) => _polygonShape[id];

  Future<void> removePolylineShape(Polyline shape) async {
    await _invokeMethod("removePolylineShape", {"polylineId": shape.id});
    _polylineShape.remove(shape.id);
  }

  Future<void> removePolygonShape(Polyline shape) async {
    await _invokeMethod("removePolygonShape", {"polygonId": shape.id});
    _polygonShape.remove(shape.id);
  }

  static const String defaultId = "vector_layer_0";
  static const int defaultZOrder = 10000;
  static const ShapeLayerPass defaultShapeLayerPass =
      ShapeLayerPass.defaultPass;
}
