part of '../kakao_map_sdk_web.dart';

class WebLabelController with WebLabelControllerHandler {
  final String id;
  final WebMapController controller;
  final bool isLod;

  @override
  final WebOverlayController manager;

  WebLabelController._(this.id, this.controller, this.manager, this.isLod);

  final Map<String, WebCustomOverlay> _webPoi = {};
  final Map<String, Map<int, String>> _preEncodedImage = {};
  final Map<String, int> _currentPoiLevel = {};

  @override
  final Map<String, String?> _poiText = {};

  @override
  final Map<String, String> _poiStyleId = {};

  @override
  Future<void> createLabelLayer() async {
    addEventListener(controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  @override
  Future<void> removeLabelLayer() async {
    for (final poi in _webPoi.keys) {
      await removePoi(poi);
    }
    removeEventListener(
        controller, "zoom_changed", _zoomChangedEventHandler.toJS);
  }

  void _zoomChangedEventHandler() {
    for (var poiId in _webPoi.keys) {
      _syncZoomLevel(poiId, _poiStyleId[poiId]!, _poiText[poiId]);
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
    final style = manager._poiStyles[styleId]!;
    if (style.icon != null) {
      _preEncodedImage[poiId]![style.zoomLevel] =
          encodeImageToBase64(await style.icon!.readBytes());
    }
    for (var inStyle in style.otherStyles) {
      if (inStyle.icon == null) continue;
      _preEncodedImage[poiId]![inStyle.zoomLevel] =
          encodeImageToBase64(await style.icon!.readBytes());
    }
    _poiStyleId[poiId] = styleId;
  }

  void _syncZoomLevel(String poiId, String styleId, String? text,
      [bool forceUpdate = false]) {
    final mapZoomLevel = controller.getLevel();
    var style = manager._poiStyles[styleId]!;
    var currentZoomLevel = style.zoomLevel;
    for (final zoomLevel in style.otherStyleLevel) {
      if (_calculateZoomLevel(zoomLevel) >= mapZoomLevel &&
          zoomLevel >= currentZoomLevel) {
        currentZoomLevel = zoomLevel;
        style = style.getStyle(zoomLevel)!;
      }
    }

    if (_currentPoiLevel[poiId] == currentZoomLevel && !forceUpdate) return;
    final encodedIcon = _preEncodedImage[poiId]![currentZoomLevel];
    _currentPoiLevel[poiId] = currentZoomLevel;
    final element = poiElement(poiId, encodedIcon, style.icon, text, style, () {
      manager._onPoiClick(id, poiId, isLod);
    });
    _webPoi[poiId]?.setContent(element);
  }

  @override
  Future<void> invalidatePoi(String poiId, String styleId, String? text,
      [bool transition = false]) async {
    await changePoiStyle(poiId, styleId, transition);
    _poiStyleId[poiId] = styleId;
    _poiText[poiId] = text;
    _syncZoomLevel(poiId, styleId, text, true);
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
    final poiId = manager._uuid.v4();

    _preEncodedImage[poiId] = {};
    if (style.icon != null) {
      _preEncodedImage[poiId]![style.zoomLevel] =
          encodeImageToBase64(await style.icon!.readBytes());
    }
    for (var inStyle in style.otherStyles) {
      if (inStyle.icon == null) continue;
      _preEncodedImage[poiId]![inStyle.zoomLevel] =
          encodeImageToBase64(await style.icon!.readBytes());
    }
    final encodedIcon = _preEncodedImage[poiId]?[style.zoomLevel];
    final options = WebCustomOverlayOption(
        clickable: true,
        content: poiElement(poiId, encodedIcon, style.icon, text, style, () {
          manager._onPoiClick(this.id, poiId, isLod);
        }),
        position: WebLatLng.fromLatLng(position),
        xAnchor: style.anchor.x.toDouble(),
        yAnchor: style.anchor.y.toDouble(),
        zIndex: rank ?? 10001);
    _currentPoiLevel[poiId] = style.zoomLevel;
    final overlay = _webPoi[poiId] = WebCustomOverlay(options);
    overlay.setMap(controller);
    overlay.setVisible(visible);
    _poiStyleId[poiId] = style.id!;
    _syncZoomLevel(poiId, style.id!, text);
    return poiId;
  }

  @override
  Future<void> removePoi(String poiId) async {
    _webPoi[poiId]?.setMap(null);
    _webPoi.remove(poiId);

    _currentPoiLevel.remove(poiId);
    _poiStyleId.remove(poiId);
    _poiText.remove(poiId);
  }

  @override
  Future<void> showAllPoi() async {
    for (var poi in _webPoi.values) {
      poi.setVisible(true);
    }
  }

  @override
  Future<void> hideAllPoi() async {
    for (var poi in _webPoi.values) {
      poi.setVisible(false);
    }
  }

  int get poiCount => _webPoi.length;
}
