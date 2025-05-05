part of '../kakao_map_sdk_web.dart';

mixin WebLabelControllerHandler {
  Future<dynamic> labelHandle(MethodCall call) async {}

  Future<void> createLabelLayer();

  Future<void> removeLabelLayer();

  Future<void> changePoiOffsetPosition(
      String poiId, double x, double y, bool forceDpScale);

  Future<void> changePoiVisible(String poiId, bool visible,
      {bool? autoMove, int? duration});

  Future<void> changePoiStyle(String poiId, String styleId,
      [bool transition = false]);

  Future<void> invalidatePoi(String poiId, String styleId, String? text,
      [bool transition = false]);

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
}
