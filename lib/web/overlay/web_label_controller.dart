part of '../kakao_map_sdk_web.dart';

class WebLabelController with WebLabelControllerHandler {
  final String id;
  final WebMapController controller;
  final bool isLod;

  @override
  final WebOverlayController manager;

  WebLabelController._(this.id, this.controller, this.manager, this.isLod);

  @override
  final Map<String, WebPoi> _webPoi = {};

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
      controller,
      "zoom_changed",
      _zoomChangedEventHandler.toJS,
    );
  }

  void _zoomChangedEventHandler() {
    for (var poiId in _webPoi.keys) {
      _syncZoomLevel(poiId);
    }
  }

  @override
  Future<void> changePoiOffsetPosition(
    String poiId,
    double x,
    double y,
    bool forceDpScale,
  ) async {}

  @override
  Future<void> changePoiVisible(
    String poiId,
    bool visible, {
    bool? autoMove,
    int? duration,
  }) async {
    _webPoi[poiId]?.setVisible(visible);
    if (autoMove ?? false) {
      final currentLevel = controller.getLevel();
      final Map<String, dynamic> animate = duration != null
          ? {
              "animate": {"duration": duration},
            }
          : {"animate": true};
      controller.jump(
        _webPoi[poiId]!.getPosition(),
        currentLevel,
        animate.jsify(),
      );
    }
  }

  @override
  Future<void> changePoiStyle(
    String poiId,
    String styleId, [
    bool transition = false,
  ]) async {
    final style = manager._poiStyles[styleId]!;
    if (style.icon != null) {
      _webPoi[poiId]!.preEncodedImage[style.zoomLevel] = encodeImageToBase64(
        await style.icon!.readBytes(),
      );
    }
    for (var inStyle in style.otherStyles) {
      if (inStyle.icon == null) continue;
      _webPoi[poiId]!.preEncodedImage[inStyle.zoomLevel] = encodeImageToBase64(
        await style.icon!.readBytes(),
      );
    }
    _webPoi[poiId]?.styleId = styleId;
  }

  /// 지도를 비추는 zoom level에 따라 적절한 Poi 스타일을 적용합니다.
  /// 다른 용도로는 Poi를 최신화하는 용도로 사용하기도 합니다.
  void _syncZoomLevel(String poiId, [bool forceUpdate = false]) {
    final poi = _webPoi[poiId]!;

    final mapZoomLevel = controller.getLevel();
    var style = manager._poiStyles[poi.styleId]!;
    var currentZoomLevel = style.zoomLevel;
    for (final zoomLevel in style.otherStyleLevel) {
      if (_calculateZoomLevel(zoomLevel) >= mapZoomLevel &&
          zoomLevel >= currentZoomLevel) {
        currentZoomLevel = zoomLevel;
        style = style.getStyle(zoomLevel)!;
      }
    }

    if (poi.currentLevel == currentZoomLevel && !forceUpdate) return;
    _webPoi[poiId]?.currentLevel = currentZoomLevel;
    final element = poiElement(poi, style);
    _webPoi[poiId]?.setContent(element);
  }

  @override
  Future<void> invalidatePoi(
    String poiId,
    String styleId,
    String? text, [
    bool transition = false,
  ]) async {
    await changePoiStyle(poiId, styleId, transition);
    _webPoi[poiId]?.styleId = styleId;
    _webPoi[poiId]?.text = text;
    _syncZoomLevel(poiId, true);
  }

  @override
  Future<void> movePoi(String poiId, LatLng position, [double? millis]) async {
    _webPoi[poiId]?.setPosition(WebLatLng.fromLatLng(position));
    manager._onPoiMove(_webPoi[poiId]!, position);
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
    final poiId = id ?? manager._uuid.v4();

    final Map<int, String> preEncodedImage = {};
    if (style.icon != null) {
      preEncodedImage[style.zoomLevel] = encodeImageToBase64(
        await style.icon!.readBytes(),
      );
    }
    for (var inStyle in style.otherStyles) {
      if (inStyle.icon == null) continue;
      preEncodedImage[inStyle.zoomLevel] = encodeImageToBase64(
        await inStyle.icon!.readBytes(),
      );
    }

    final poi = _webPoi[poiId] = WebPoi(
      poiId,
      this.id,
      currentLevel: style.zoomLevel,
      text: text,
      styleId: style.id!,
      onClick: () {
        manager._onPoiClick(this.id, poiId, isLod);
      },
    );

    poi.preEncodedImage.addAll(preEncodedImage);
    final options = WebCustomOverlayOption(
      clickable: true,
      content: poiElement(poi, style),
      position: WebLatLng.fromLatLng(position),
      xAnchor: style.anchor.x.toDouble(),
      yAnchor: style.anchor.y.toDouble(),
      zIndex: rank ?? 10001,
    );
    poi.overlay = WebCustomOverlay(options);

    poi.setMap(controller);
    poi.setVisible(visible);

    _syncZoomLevel(poiId);
    return poiId;
  }

  @override
  Future<void> removePoi(String poiId) async {
    _webPoi[poiId]?.setMap(null);
    _webPoi.remove(poiId);
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

  @override
  Future<String> addPoiBadge(
    String poiId,
    KImage image,
    double offsetX,
    double offsetY, {
    String? badgeId,
    int? zOrder,
    bool visible = true,
  }) async {
    final tBadgeId = badgeId ?? manager._uuid.v4();
    final badge = _webPoi[poiId]?.badge[tBadgeId] = WebPoiBadge(
      tBadgeId,
      offsetX,
      offsetY,
      image,
      visible,
      zOrder ?? 0,
    );
    await badge!.encodeImage();
    _syncZoomLevel(poiId, true);
    return tBadgeId;
  }

  @override
  Future<void> removePoiBadge(String poiId, String badgeId) async {
    _webPoi[poiId]?.badge.remove(badgeId);
    _syncZoomLevel(poiId, true);
  }

  @override
  Future<void> changePoiBadgeVisible(
    String poiId,
    String badgeId,
    bool visible,
  ) async {
    _webPoi[poiId]?.badge[badgeId]!.visible = visible;
    _syncZoomLevel(poiId, true);
  }

  @override
  Future<void> addShareTransformPoi(
    String poiId,
    String targetLayerId,
    String targetPoiId,
  ) async {
    final targetPoi = manager._labelLayer[targetLayerId]?._webPoi[targetPoiId];
    _webPoi[poiId]!.shareTransformPoi.add(targetPoi!);
  }

  // @override
  // Future<void> addShareTransformPoiWithShape(
  //     String poiId, String targetLayerId, String targetShapeId) async {}

  @override
  Future<void> removeShareTransformPoi(
    String poiId,
    String targetLayerId,
    String targetPoiId,
  ) async {
    _webPoi[poiId]!.shareTransformPoi.removeWhere(
          (poi) => poi.id == targetPoiId && poi.layerId == targetLayerId,
        );
  }

  // @override
  // Future<void> removeShareTransformPoiWithShape(
  //     String poiId, String targetLayerId, String targetShapeId) async {}

  int get poiCount => _webPoi.length;
}
