part of '../../kakao_map_sdk.dart';

class WebLabelController extends LabelController {
  final WebMapController controller;

  WebLabelController._(this.controller, super.channel, super.manager, super.id,
      {super.competitionType,
      super.competitionUnit,
      super.orderingType,
      super.visible,
      super.clickable,
      super.zOrder})
      : super._();

  @override
  Future<void> _createLabelLayer() async {}

  @override
  Future<void> _removeLabelLayer() async {}

  @override
  Future<void> _changePoiOffsetPosition(
      String poiId, double x, double y, bool forceDpScale) async {}

  @override
  Future<void> _changePoiVisible(String poiId, bool visible,
      {bool? autoMove, int? duration}) async {}

  @override
  Future<void> _changePoiStyle(String poiId, String styleId,
      [bool transition = false]) async {}

  Future<void> _invalidatePoi(String poiId, String styleId, String? text,
      [bool transition = false]) async {}

  @override
  Future<void> _movePoi(String poiId, LatLng position,
      [double? millis]) async {}

  @override
  Future<void> _rotatePoi(String poiId, double angle, [double? millis]) async {}

  @override
  Future<void> _scalePoi(String poiId, double x, double y,
      [double? millis]) async {}

  @override
  Future<void> _rankPoi(String poiId, int rank) async {}

  @override
  Future<void> _changePolylineTextStyle(String poiId, PolylineTextStyle style,
      [String? text]) async {}

  @override
  Future<void> _changePolylineTextVisible(String labelId, bool visible) async {}

  @override
  Future<Poi> addPoi(
    LatLng position, {
    required PoiStyle style,
    String? id,
    String? text,
    TransformMethod? transform,
    int? rank,
    void Function()? onClick,
    bool visible = true,
  }) async {
    if (id != null && _poi.containsKey(id)) {
      throw DuplicatedOverlayException(id);
    }
    final styleId = style.id ?? await manager.addPoiStyle(style);
    final poiId = "custom_overlay_$poiCount";
    final webPoiOption = WebCustomOverlayOption(
      clickable: true,
      content: "<span id='$poiId'>Hello World</span>",
      zIndex: rank ?? 10001,
      position: WebLatLng.fromLatLng(position)
    );
    final webPoi = WebCustomOverlay(webPoiOption);
    webPoi.setMap(controller);

    final poi = Poi._(this, poiId,
        transform: transform,
        position: position,
        style: style,
        text: text,
        rank: rank ?? 0,
        visible: visible,
        onClick: onClick);
    _poi[poiId] = poi;
    return poi;
  }

  @override
  Future<void> removePoi(Poi poi) async {
    _poi.remove(poi.id);
  }

  @override
  Future<void> showAllPoi() async {}

  @override
  Future<void> hideAllPoi() async {}

  @override
  Future<PolylineText> addPolylineText(
    String text,
    List<LatLng> position, {
    required PolylineTextStyle style,
    String? id,
    bool visible = true,
  }) =>
      throw UnimplementedError();

  @override
  PolylineText? getPolylineText(String id) => null;

  @override
  Future<void> removePolylineText(PolylineText label) async {}

  @override
  Future<void> showAllPolylineText() async {}

  @override
  Future<void> hideAllPolylineText() async {}
}
