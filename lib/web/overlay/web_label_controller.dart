part of '../../kakao_map_sdk.dart';

class WebLabelController extends LabelController {
  final WebMapController controller;

  WebLabelController._(this.controller, super.channel, super.manager, super.id)
      : super._();

  final Map<String, WebCustomOverlay> _webPoi = {};
  final Map<String, Map<int, String>> _preEncodedImage = {};
  final Map<String, int> _currentPoiLevel = {};

  @override
  Future<void> _createLabelLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> _removeLabelLayer() async {
    for (final poi in _poi.values) {
      await removePoi(poi);
    }
    removeEventListener(
        controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  void _zoomChangedEventHandler() {
    for (var poi in _poi.values) {
      _syncZoomLevel(poi.id, poi.style.id!, poi.text);
    }
  }

  @override
  Future<void> _changePoiOffsetPosition(
      String poiId, double x, double y, bool forceDpScale) async {}

  @override
  Future<void> _changePoiVisible(String poiId, bool visible,
      {bool? autoMove, int? duration}) async {
    _webPoi[poiId]?.setVisible(visible);
    if (autoMove ?? false) {
      final currentLevel = controller.getLevel();
      final Map<String, dynamic> animate = duration != null
          ? {
              "animate": {"duration": duration}
            }
          : {"animate": true};
      controller.jump(
          _webPoi[poiId]!.getPosition(), currentLevel, animate.jsify());
    }
  }

  @override
  Future<void> _changePoiStyle(String poiId, String styleId,
      [bool transition = false]) async {
    final style = manager.getPoiStyle(styleId)!;
    if (style.icon != null) {
      _preEncodedImage[poiId]![style.zoomLevel] =
          encodeImageToBase64(await convertImageToData(style.icon!));
    }
    for (var inStyle in style._styles) {
      if (inStyle.icon == null) continue;
      _preEncodedImage[poiId]![inStyle.zoomLevel] =
          encodeImageToBase64(await convertImageToData(inStyle.icon!));
    }
  }

  static int calculateZoomLevel(int zoomLevel) =>
      KakaoMapWebController.calculateZoomLevel(zoomLevel);

  void _syncZoomLevel(String poiId, String styleId, String? text) {
    final poi = _poi[poiId]!;
    final mapZoomLevel = controller.getLevel();
    var currentZoomLevel = poi.style.zoomLevel;
    var style = poi.style;
    for (final secondaryStyle in poi.style._styles) {
      if (calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
          secondaryStyle.zoomLevel >= currentZoomLevel) {
        currentZoomLevel = secondaryStyle.zoomLevel;
        style = poi.style._styles[currentZoomLevel];
      }
    }

    if (_currentPoiLevel[poiId] == currentZoomLevel) return;
    final encodedIcon = _preEncodedImage[poiId]![currentZoomLevel];
    _currentPoiLevel[poiId] = currentZoomLevel;
    final element =
        poiElement(poiId, encodedIcon, style.icon, text, style, poi.onClick);
    _webPoi[poiId]?.setContent(element);
  }

  @override
  Future<void> _invalidatePoi(String poiId, String styleId, String? text,
      [bool transition = false]) async {
    await _changePoiStyle(poiId, styleId, transition);
    _syncZoomLevel(poiId, styleId, text);
  }

  @override
  Future<void> _movePoi(String poiId, LatLng position, [double? millis]) async {
    _webPoi[poiId]?.setPosition(WebLatLng.fromLatLng(position));
  }

  @override
  Future<void> _rotatePoi(String poiId, double angle, [double? millis]) async {
    final element = _webPoi[poiId]?.getContent() as web.HTMLElement;
    element.style.rotate = "${angle.toInt()}deg";
    _webPoi[poiId]?.setContent(element);
  }

  @override
  Future<void> _scalePoi(String poiId, double x, double y,
      [double? millis]) async {}

  @override
  Future<void> _rankPoi(String poiId, int rank) async {
    _webPoi[poiId]?.setZIndex(rank);
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

    _preEncodedImage[poiId] = {};
    if (style.icon != null) {
      _preEncodedImage[poiId]![style.zoomLevel] =
          encodeImageToBase64(await convertImageToData(style.icon!));
    }
    for (var inStyle in style._styles) {
      if (inStyle.icon == null) continue;
      _preEncodedImage[poiId]![inStyle.zoomLevel] =
          encodeImageToBase64(await convertImageToData(inStyle.icon!));
    }
    final encodedIcon = _preEncodedImage[poiId]?[style.zoomLevel];
    final options = WebCustomOverlayOption(
        clickable: true,
        content:
            poiElement(poiId, encodedIcon, style.icon, text, style, onClick),
        position: WebLatLng.fromLatLng(position),
        xAnchor: style.anchor.x.toDouble(),
        yAnchor: style.anchor.y.toDouble(),
        zIndex: rank ?? 10001);
    _currentPoiLevel[poiId] = style.zoomLevel;
    final overlay = _webPoi[poiId] = WebCustomOverlay(options);
    overlay.setMap(controller);
    overlay.setVisible(visible);

    final poi = Poi._(this, poiId,
        transform: transform,
        position: position,
        style: style,
        text: text,
        rank: rank ?? 0,
        visible: visible,
        onClick: onClick);
    _poi[poiId] = poi;
    _syncZoomLevel(poiId, style.id!, text);
    return poi;
  }

  @override
  Future<void> removePoi(Poi poi) async {
    _webPoi[poi.id]?.setMap(null);
    _webPoi.remove(poi.id);
    _poi.remove(poi.id);
  }

  @override
  Future<void> showAllPoi() async {
    for (var poi in _poi.values) {
      await poi.show();
    }
  }

  @override
  Future<void> hideAllPoi() async {
    for (var poi in _poi.values) {
      await poi.hide();
    }
  }

  @override
  Future<void> _changePolylineTextStyle(String poiId, PolylineTextStyle style,
      [String? text]) async {}

  @override
  Future<void> _changePolylineTextVisible(String labelId, bool visible) async {}

  @override
  Future<PolylineText> addPolylineText(
    String text,
    List<LatLng> position, {
    required PolylineTextStyle style,
    String? id,
    bool visible = true,
  }) async =>
      PolylineText._(this, id ?? "dummy_polyline_text",
          style: style, text: text, points: position, visible: visible);

  @override
  PolylineText? getPolylineText(String id) => null;

  @override
  Future<void> removePolylineText(PolylineText label) async {}

  @override
  Future<void> showAllPolylineText() async {}

  @override
  Future<void> hideAllPolylineText() async {}
}
