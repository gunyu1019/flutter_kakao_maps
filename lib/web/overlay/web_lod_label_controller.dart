part of '../../kakao_map_sdk.dart';

class WebLodLabelController extends LodLabelController {
  final WebMapController controller;

  WebLodLabelController._(
      this.controller, super.channel, super.manager, super.id)
      : super._();

  final Map<String, WebCustomOverlay> _webPoi = {};
  final Map<String, Map<int, String>> _preEncodedImage = {};
  final Map<String, int> _currentPoiLevel = {};

  @override
  Future<void> _createLodLabelLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> _removeLodLabelLayer() async {
    for (final poi in _poi.values) {
      await removeLodPoi(poi);
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
    var style = poi.style;
    var currentZoomLevel = poi.style.zoomLevel;
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
  Future<void> _rankPoi(String poiId, int rank) async {
    _webPoi[poiId]?.setZIndex(rank);
  }

  @override
  Future<LodPoi> addLodPoi(
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
    final poiId = "custom_overlay_lod_${this.id}_$poiCount";

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
        xAnchor: style.anchor.x,
        yAnchor: style.anchor.y,
        zIndex: rank ?? 10001);
    _currentPoiLevel[poiId] = style.zoomLevel;
    final overlay = _webPoi[poiId] = WebCustomOverlay(options);
    overlay.setMap(controller);
    overlay.setVisible(visible);

    final poi = LodPoi._(this, poiId,
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
  Future<void> removeLodPoi(LodPoi poi) async {
    _webPoi[poi.id]?.setMap(null);
    _webPoi.remove(poi.id);
    _poi.remove(poi.id);
  }

  @override
  Future<void> showAllLodPoi() async {
    for (var poi in _poi.values) {
      await poi.show();
    }
  }

  @override
  Future<void> hideAllLodPoi() async {
    for (var poi in _poi.values) {
      await poi.hide();
    }
  }
}
