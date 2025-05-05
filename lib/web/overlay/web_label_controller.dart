part of '../kakao_map_sdk_web.dart';

class WebLabelController with WebLabelControllerHandler {
  final WebMapController controller;

  WebLabelController._(this.controller);

  final Map<String, WebCustomOverlay> _webPoi = {};
  final Map<String, Map<int, String>> _preEncodedImage = {};
  final Map<String, int> _currentPoiLevel = {};

  @override
  Future<void> createLabelLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> removeLabelLayer() async {
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
  Future<void> changePoiOffsetPosition(
      String poiId, double x, double y, bool forceDpScale) async {}

  @override
  Future<void> changePoiVisible(String poiId, bool visible,
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
  Future<void> changePoiStyle(String poiId, String styleId,
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

  void _syncZoomLevel(String poiId, String styleId, String? text) {
    final poi = _poi[poiId]!;
    final mapZoomLevel = controller.getLevel();
    var currentZoomLevel = poi.style.zoomLevel;
    var style = poi.style;
    for (final secondaryStyle in poi.style._styles) {
      if (_calculateZoomLevel(secondaryStyle.zoomLevel) >= mapZoomLevel &&
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
  Future<void> invalidatePoi(String poiId, String styleId, String? text,
      [bool transition = false]) async {
    await _changePoiStyle(poiId, styleId, transition);
    _syncZoomLevel(poiId, styleId, text);
  }

  @override
  Future<void> movePoi(String poiId, LatLng position, [double? millis]) async {
    _webPoi[poiId]?.setPosition(WebLatLng.fromLatLng(position));
  }

  @override
  Future<void> rotatePoi(String poiId, double angle, [double? millis]) async {
    final element = _webPoi[poiId]?.getContent() as web.HTMLElement;
    element.style.rotate = "${angle.toInt()}deg";
    _webPoi[poiId]?.setContent(element);
  }

  @override
  Future<void> rankPoi(String poiId, int rank) async {
    _webPoi[poiId]?.setZIndex(rank);
  }

  @override
  Future<String> addPoi(
    LatLng position, {
    required PoiStyle style,
    String? id,
    String? text,
    int? rank,
    bool visible = true,
  }) async {
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

    _syncZoomLevel(poiId, style.id!, text);
    return poi;
  }

  @override
  Future<void> removePoi(Poi poi) async {
    _webPoi[poi.id]?.setMap(null);
    _webPoi.remove(poi.id);
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
}
