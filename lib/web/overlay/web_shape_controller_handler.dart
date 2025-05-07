part of '../kakao_map_sdk_web.dart';

mixin WebShapeControllerHandler {
  WebOverlayController get manager;

  Future<dynamic> shapeHandle(MethodCall method) async {
    final arguments = method.arguments;
    final shapeId = arguments["shapeId"];

    switch (method.method) {
      case "createShapeLayer":
        await createShapeLayer();
        break;
      case "removeShapeLayer":
        await removeShapeLayer();
        break;
      case "addPolylineShape":
        final polyline = arguments["polyline"];
        final point = WebShapePoint.fromMessageable(polyline["position"]);
        final style = manager._polylineStyles[polyline["styleId"]!]![0];
        return await addPolylineShape(point, style,
            id: polyline["id"], zOrder: polyline["zOrder"] ?? 10001);
      case "addPolygonShape":
        final polygon = arguments["polygon"];
        final point = WebShapePoint.fromMessageable(polygon["position"]);
        final style = manager._polygonStyles[polygon["styleId"]!]![0];
        return await addPolygonShape(point, style,
            id: polygon["id"], zOrder: polygon["zOrder"] ?? 10001);
      case "removePolylineShape":
      case "removePolygonShape":
      case "changePolylineVisible":
      case "changePolygonVisible":
      case "changePolyline":
      case "changePolygon":
      case "changeVisibleAllPolyline":
      case "changeVisibleAllPolygon":
      default:
        throw UnimplementedError();
    }
  }

  Future<void> createShapeLayer();

  Future<void> removeShapeLayer();

  Future<void> changePolylineVisible(String shapeId, bool visible);

  Future<void> changePolygonVisible(String shapeId, bool visible);

  Future<void> changePolyline(
      String shapeId, WebShapePoint point, String styleId);

  Future<void> changePolygon(
      String shapeId, WebShapePoint point, String styleId);

  Future<String> addPolylineShape(WebShapePoint point, PolylineStyle style,
      {String? id, int zOrder = 10001});

  Future<String> addPolygonShape(WebShapePoint point, PolygonStyle style,
      {String? id, int zOrder = 10001});

  Future<void> removePolylineShape(String shapeId);

  Future<void> removePolygonShape(String shapeId);

  Future<void> showAllPolyline();

  Future<void> hideAllPolyline();

  Future<void> showAllPolygon();

  Future<void> hideAllPolygon();
}
