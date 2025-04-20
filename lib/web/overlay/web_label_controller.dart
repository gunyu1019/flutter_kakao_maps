part of '../../kakao_map_sdk.dart';

class WebLabelController extends LabelController {
  final WebMapController controller;

  WebLabelController._(this.controller, super.channel, super.manager, super.id)
      : super._();

  final Map<String, WebPoi> _webPoi = {};

  @override
  Future<void> _createLabelLayer() async {}

  @override
  Future<void> _removeLabelLayer() async {
    for (final poi in _poi.values) {
      await removePoi(poi);
    }
  }

  @override
  Future<void> _changePoiOffsetPosition(
      String poiId, double x, double y, bool forceDpScale) async {}

  @override
  Future<void> _changePoiVisible(String poiId, bool visible,
      {bool? autoMove, int? duration}) async {
    // 구현 확정 (setVisible)
  }

  @override
  Future<void> _changePoiStyle(String poiId, String styleId,
      [bool transition = false]) async {
    // 구현 확정 (setContent)
  }

  Future<void> _invalidatePoi(String poiId, String styleId, String? text,
      [bool transition = false]) async {
    // 구현 확정 (setContent)
  }

  @override
  Future<void> _movePoi(String poiId, LatLng position, [double? millis]) async {
    _webPoi[poiId]?.elements.forEach(
        (element) => element.setPosition(WebLatLng.fromLatLng(position)));
  }

  @override
  Future<void> _rotatePoi(String poiId, double angle, [double? millis]) async {}

  @override
  Future<void> _scalePoi(String poiId, double x, double y,
      [double? millis]) async {}

  @override
  Future<void> _rankPoi(String poiId, int rank) async {
    _webPoi[poiId]?.elements.forEach((element) => element.setZIndex(rank));
  }

  @override
  Future<void> _changePolylineTextStyle(String poiId, PolylineTextStyle style,
      [String? text]) async {}

  @override
  Future<void> _changePolylineTextVisible(String labelId, bool visible) async {}

  Future<WebPoi> _addPoiElement(String poiId, PoiStyle style, LatLng position,
      String? text, int? rank, bool visible) async {
    final imageAnchorY = text == null ? style.anchor.y : 1.0;
    final textAnchorY = text == null ? style.anchor.y : 0.0;
    WebCustomOverlay? webImagePoi;
    WebCustomOverlay? webTextPoi;

    if (style.icon != null) {
      final imageContent = (await imageElement(style.icon!))
        ..id = "${poiId}_image_${style.zoomLevel}";
      final webImagePoiOption = WebCustomOverlayOption(
          clickable: true,
          content: imageContent.outerHTML.dartify() as String,
          zIndex: rank ?? 10001,
          position: WebLatLng.fromLatLng(position),
          xAnchor: style.anchor.x,
          yAnchor: imageAnchorY);
      webImagePoi = WebCustomOverlay(webImagePoiOption);
      webImagePoi.setMap(controller);
      webImagePoi.setVisible(visible);
    }
    if (text != null) {
      final textContent = web.HTMLDivElement()
        ..id = "${poiId}_text_${style.zoomLevel}";
      text
          .split("\n")
          .mapIndexed(
              (index, element) => textElement(element, style.textStyle[index]))
          .forEach((element) => textContent.appendChild(element));
      final webTextPoiOption = WebCustomOverlayOption(
          clickable: true,
          content: textContent.outerHTML.dartify() as String,
          zIndex: rank ?? 10001,
          position: WebLatLng.fromLatLng(position),
          xAnchor: style.anchor.x,
          yAnchor: textAnchorY);
      webTextPoi = WebCustomOverlay(webTextPoiOption);
      webTextPoi.setMap(controller);
      webTextPoi.setVisible(visible);
    }
    return WebPoi(webImagePoi, webTextPoi, visible);
  }

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
    if (style.id == null) {
      await manager.addPoiStyle(style);
    }

    final poiId = "custom_overlay_${this.id}_$poiCount";
    _webPoi[poiId] =
        await _addPoiElement(poiId, style, position, text, rank, visible);

    // zoomLevel에 따른 element 추가
    for (var secondaryStyle in style._styles) {
      final otherPoi = await _addPoiElement(
          poiId, secondaryStyle, position, text, rank, false);
      if (otherPoi.imageElement != null) {
        _webPoi[poiId]!.otherImageElement[secondaryStyle.zoomLevel] =
            otherPoi.imageElement!;
      }
      if (otherPoi.textElement != null) {
        _webPoi[poiId]!.otherTextElement[secondaryStyle.zoomLevel] =
            otherPoi.textElement!;
      }
    }

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
    _webPoi[poi.id]?.elements.forEach((element) => element.setMap(null));
    _webPoi.remove(poi.id);
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
