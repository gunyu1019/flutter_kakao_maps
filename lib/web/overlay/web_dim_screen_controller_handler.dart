part of '../kakao_map_sdk_web.dart';

mixin WebDimScreenControllerHandler {
  WebOverlayController get manager;

  Future<dynamic> dimScreenHandle(MethodCall method) async {
    final arguments = method.arguments;

    switch (method.method) {
      case "createDimScreenLayer":
        await createDimScreenLayer();
        return;
      case "removeDimScreenLayer":
        await removeDimScreenLayer();
        return;
      case "setColor":
        await setDimColor(arguments["color"]);
        return;
      case "setVisible":
        await setDimVisible(arguments["visible"]);
        return;
      case "setDimCover":
        final cover = DimScreenCover.values.firstWhere(
          (e) => e.value == arguments["cover"],
        );
        await setDimCover(cover);
        return;
      case "addHighlightPolygonShape":
        final polygon = arguments["polygon"];
        final point = WebShapePoint.fromMessageable(polygon["position"]);
        final style = manager._dimPolygonStyles[polygon["styleId"]!]![0];
        return await addHighlightPolygonShape(
          point,
          style,
          id: polygon["id"],
          zOrder: polygon["zOrder"] ?? 10001,
        );
      case "removeHighlightPolygonShape":
        final shapeId = arguments["polygonId"];
        await removeHighlightPolygonShape(shapeId);
        return;
      case "changePolygonVisible":
        final shapeId = arguments["polygonId"];
        final visible = arguments["visible"];
        await changePolygonVisible(shapeId, visible);
        return;
      case "changePolygon":
        final shapeId = arguments["polygonId"];
        final point = WebShapePoint.fromMessageable(arguments["position"]);
        final style = manager._dimPolygonStyles[arguments["styleId"]!]![0];
        await changePolygon(shapeId, point, style);
        return;
      default:
        throw UnimplementedError();
    }
  }

  Future<void> createDimScreenLayer();

  Future<void> removeDimScreenLayer();

  Future<void> setDimColor(int color);

  Future<void> setDimVisible(bool visible);

  Future<void> setDimCover(DimScreenCover cover);

  Future<String> addHighlightPolygonShape(
    WebShapePoint point,
    PolygonStyle style, {
    String? id,
    int zOrder = 10001,
  });

  Future<void> removeHighlightPolygonShape(String shapeId);

  Future<void> changePolygonVisible(String shapeId, bool visible);

  Future<void> changePolygon(
    String shapeId,
    WebShapePoint point,
    PolygonStyle style,
  );
}
