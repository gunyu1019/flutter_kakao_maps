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
      default:
        throw UnimplementedError();
    }
  }

  Future<void> createShapeLayer();

  Future<void> removeShapeLayer();

  Future<void> changePolylineVisible(String shapeId, bool visible);

  Future<void> changePolygonVisible(String shapeId, bool visible);

  Future<void> changePolyline(
      String shapeId, MapPoint position, String styleId);

  Future<void> changePolygon(String shapeId, MapPoint position, String styleId);

  Future<String> addPolylineShape(
      MapPoint position, PolylineStyle style, PolylineCap polylineCap,
      {String? id, int zOrder = 10001});

  Future<Polygon> addPolygonShape(MapPoint position, PolygonStyle style,
      {String? id, int zOrder = 10001});

  Future<void> removePolylineShape(String shapeId);

  Future<void> removePolygonShape(String shapeId);

  Future<void> showAllPolyline();

  Future<void> hideAllPolyline();

  Future<void> showAllPolygon();

  Future<void> hideAllPolygon();
}
