part of '../kakao_map_sdk_web.dart';

mixin WebShapeControllerHandler {
  WebOverlayController get manager;

  Future<dynamic> shapeHandle(MethodCall method) async {
    final arguments = method.arguments;

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
        final shapeId = arguments["polylineId"];
        await removePolylineShape(shapeId);
        break;
      case "removePolygonShape":
        final shapeId = arguments["polygonId"];
        await removePolygonShape(shapeId);
        break;
      case "changePolylineVisible":
        final shapeId = arguments["polylineId"];
        final visible = arguments["visible"];
        await changePolylineVisible(shapeId, visible);
        break;
      case "changePolygonVisible":
        final shapeId = arguments["polygonId"];
        final visible = arguments["visible"];
        await changePolygonVisible(shapeId, visible);
        break;
      case "changePolyline":
        final shapeId = arguments["polylineId"];
        final point = WebShapePoint.fromMessageable(arguments["position"]);
        final styleId = arguments["styleId"]!;
        await changePolyline(shapeId, point, styleId);
        break;
      case "changePolygon":
        final shapeId = arguments["polygonId"];
        final point = WebShapePoint.fromMessageable(arguments["position"]);
        final styleId = arguments["styleId"]!;
        await changePolygon(shapeId, point, styleId);
        break;
      case "changeVisibleAllPolyline":
        if (arguments["visible"]) {
          await showAllPolyline();
        } else {
          await hideAllPolyline();
        }
        break;
      case "changeVisibleAllPolygon":
        if (arguments["visible"]) {
          await showAllPolygon();
        } else {
          await hideAllPolygon();
        }
        break;
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
