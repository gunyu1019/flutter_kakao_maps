part of '../kakao_map_sdk_web.dart';

mixin WebLabelControllerHandler {
  WebOverlayController get manager;

  Map<String, WebPoi> get _webPoi;

  Future<dynamic> labelHandle(MethodCall method) async {
    final arguments = method.arguments;
    final poiId = arguments["poiId"];
    final badgeId = arguments["badgeId"];

    switch (method.method) {
      case "createLabelLayer" || "createLodLabelLayer":
        await createLabelLayer();
        break;
      case "removeLabelLayer" || "removeLodLabelLayer":
        await removeLabelLayer();
        break;
      case "addPoi" || "addLodPoi":
        final poi = arguments["poi"];
        final position = LatLng.fromMessageable(poi);
        final style = manager._poiStyles[poi["styleId"]!]!;
        return await addPoi(
          position,
          style: style,
          text: poi["text"],
          rank: poi["rank"],
          visible: poi["visible"] ?? true,
          id: poi["id"],
        );
      case "removePoi" || "removeLodPoi":
        await removePoi(poiId!);
        break;
      case "changePoiOffsetPosition":
        await changePoiOffsetPosition(
          poiId,
          arguments["x"],
          arguments["y"],
          arguments["forceDpScale"],
        );
        break;
      case "changePoiVisible":
        await changePoiVisible(
          poiId,
          arguments["visible"],
          autoMove: arguments["autoMove"],
          duration: arguments["millis"],
        );
        break;
      case "changePoiStyle":
        await changePoiStyle(
          poiId,
          arguments["styleId"],
          arguments["transition"],
        );
        break;
      case "changePoiText":
        final styleId = arguments["styleId"] ?? _webPoi[poiId]?.styleId;
        await invalidatePoi(
          poiId,
          styleId,
          arguments["text"],
          arguments["transition"],
        );
        break;
      case "invalidatePoi":
        final styleId = arguments["styleId"] ?? _webPoi[poiId]?.styleId;
        final text = arguments["text"] ?? _webPoi[poiId]?.text;
        await invalidatePoi(poiId, styleId, text, arguments["transition"]);
        break;
      case "movePoi":
        await movePoi(
          poiId,
          LatLng.fromMessageable(arguments),
          arguments["millis"],
        );
        break;
      case "rotatePoi":
        await rotatePoi(poiId, arguments["angle"], arguments["millis"]);
        break;
      case "rankPoi":
        await rankPoi(poiId, arguments["rank"]);
        break;
      case "changeVisibleAllPoi" || "changeVisibleAllLodPoi":
        if (arguments["visible"]) {
          await showAllPoi();
        } else {
          await hideAllPoi();
        }
        break;
      case "addPoiBadge":
        final badgeOption = arguments["badge"];
        final badgeImage = KImage.fromMessageable(badgeOption["image"]);
        return await addPoiBadge(
          poiId,
          badgeImage,
          badgeOption["offsetX"],
          badgeOption["offsetY"],
          badgeId: badgeOption["id"],
          zOrder: badgeOption["zOrder"] ?? 1,
          visible: badgeOption["visible"] ?? true,
        );
      case "removePoiBadge":
        removePoiBadge(poiId, badgeId);
        break;
      case "changePoiBadgeVisible":
        changePoiBadgeVisible(poiId, badgeId, arguments["visible"]);
        break;
      case "addShareTransformPoi" || "addSharePositionPoi":
        final targetLayerId = arguments["targetLabelLayerId"];
        final targetPoiId = arguments["targetPoiId"];
        addShareTransformPoi(poiId, targetLayerId, targetPoiId);
        break;
      case "removeShareTransformPoi" || "removeSharePositionPoi":
        final targetLayerId = arguments["targetLabelLayerId"];
        final targetPoiId = arguments["targetPoiId"];
        removeShareTransformPoi(poiId, targetLayerId, targetPoiId);
        break;
      case "changePolylineTextStyle" ||
            "changePolylineTextVisible" ||
            "changeVisibleAllPolylineText" ||
            "setLayerClickable" ||
            "setLayerZOrder" ||
            "scalePoi" ||
            "addShareTransformShape" ||
            "removeShareTransformShape" ||
            "movePathPoi":
        break;
      default:
        throw UnimplementedError();
    }
  }

  Future<void> createLabelLayer();

  Future<void> removeLabelLayer();

  Future<void> changePoiOffsetPosition(
    String poiId,
    double x,
    double y,
    bool forceDpScale,
  );

  Future<void> changePoiVisible(
    String poiId,
    bool visible, {
    bool? autoMove,
    int? duration,
  });

  Future<void> changePoiStyle(
    String poiId,
    String styleId, [
    bool transition = false,
  ]);

  Future<void> invalidatePoi(
    String poiId,
    String styleId,
    String? text, [
    bool transition = false,
  ]);

  Future<void> movePoi(String poiId, LatLng position, [double? millis]);

  Future<void> rotatePoi(String poiId, double angle, [double? millis]);

  // Future<void> _scalePoi(String poiId, double x, double y, [double? millis]);

  Future<void> rankPoi(String poiId, int rank);

  Future<String> addPoi(
    LatLng position, {
    required PoiStyle style,
    String? id,
    String? text,
    int? rank,
    bool visible = true,
  });

  Future<void> removePoi(String poiId);

  Future<void> showAllPoi();

  Future<void> hideAllPoi();

  Future<String> addPoiBadge(
    String poiId,
    KImage image,
    double offsetX,
    double offsetY, {
    String? badgeId,
    int? zOrder,
    bool visible = true,
  });

  Future<void> removePoiBadge(String poiId, String badgeId);

  Future<void> changePoiBadgeVisible(
    String poiId,
    String badgeId,
    bool visible,
  );

  Future<void> addShareTransformPoi(
    String poiId,
    String targetLayerId,
    String targetPoiId,
  );

  // Future<void> addShareTransformPoiWithShape(
  //     String poiId, String targetLayerId, String targetShapeId);

  Future<void> removeShareTransformPoi(
    String poiId,
    String targetLayerId,
    String targetPoiId,
  );

  // Future<void> removeShareTransformPoiWithShape(
  //     String poiId, String targetLayerId, String targetShapeId);

  // Future<void> movePathPoi(String poiId, List<LatLng> path, int duration, double cornerRadius, double jumpThreshold);
}
