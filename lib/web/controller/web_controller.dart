part of '../kakao_map_sdk_web.dart';

/// [KakaoMapController]를 웹 환경에서 사용할 수 있도록 구현하는 객체입니다.
class KakaoMapWebController
    with KakaoMapControllerHandler, KakaoMapWebControllerHandler {
  late WebMapController controller;
  late WebOverlayController overlay;
  final MethodChannel channel;
  final MethodChannel overlayChannel;

  KakaoMapWebController({
    WebMapController? controller,
    required this.channel,
    required this.overlayChannel,
  }) {
    if (controller == null) {
      final error = KakaoMapError("KAKAO_MAP_WEB_LOAD_FAILED",
          "Timeout loading map elements. Please retry later.");
      onMapError(error);
      return;
    }
    overlay = WebOverlayController(
        overlayChannel, controller, onPoiClick, onLodPoiClick);

    // ignore: prefer_initializing_formals
    this.controller = controller;

    web.window.addEventListener('resize', _resizedEvent.toJS);
    channel.setMethodCallHandler(webHandle);
    onMapReady();
  }

  void _resizedEvent() => controller.relayout();

  @override
  Future<void> setEventTrigger(int event) async {
    if (EventType.onCameraMoveStart.compareTo(event)) {
      addEventListener(
          controller,
          "zoom_start",
          (() {
            onCameraMoveStart(GestureType.zoom);
          }).toJS);
      addEventListener(
          controller,
          "dragstart",
          (() {
            onCameraMoveStart(GestureType.pan);
          }).toJS);
    }
    if (EventType.onCameraMoveEnd.compareTo(event)) {
      addEventListener(
          controller,
          "dragend",
          (() {
            getCameraPosition().then((position) {
              onCameraMoveEnd(position, GestureType.pan);
            });
          }).toJS);
      addEventListener(
          controller,
          "zoom_changed",
          (() {
            getCameraPosition().then((position) {
              onCameraMoveEnd(position, GestureType.zoom);
            });
          }).toJS);
      addEventListener(
          controller,
          "dblclick",
          (() {
            getCameraPosition().then((position) {
              onCameraMoveEnd(position, GestureType.oneFingerDoubleTap);
            });
          }).toJS);
    }
    if (EventType.onMapClick.compareTo(event) ||
        EventType.onTerrainClick.compareTo(event)) {
      addEventListener(
          controller,
          "click",
          ((WebMouseEvent mouse) {
            onMapClick.call(mouse.getPoint(), mouse.getPosition());
            onTerrainClick.call(mouse.getPoint(), mouse.getPosition());
          }).toJS);
    }
    if (EventType.onTerrainLongClick.compareTo(event)) {
      addEventListener(
          controller,
          "rightclick",
          ((WebMouseEvent mouse) {
            onTerrainLongClick.call(mouse.getPoint(), mouse.getPosition());
          }).toJS);
    }
  }

  @override
  Future<bool> canShowPosition(int zoomLevel, List<LatLng> position) async {
    final bound = controller.getBounds();
    final ne = bound.getNorthEast();
    final sw = bound.getSouthWest();
    return !position.any((point) =>
        point.latitude > ne.getLat() ||
        point.latitude < sw.getLat() ||
        point.longitude > ne.getLng() ||
        point.longitude < sw.getLng());
  }

  @override
  Future<void> changeMapType(MapType mapType) async {
    final mapTypeId = switch (mapType) {
      MapType.normal => 1,
      MapType.skyview => 2,
    };
    controller.setMapTypeId(mapTypeId);
  }

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> clearDiskCache() async {}

  @override
  Future<double> getBuildingHeightScale() async => 0.0;

  @override
  Future<dynamic> fromScreenPoint(int x, int y) async {
    final protection = controller.getProjection();
    return protection
        .coordsFromContainerPoint(WebPoint(x.toDouble(), y.toDouble()))
        .toLatLng()
        .toMessageable();
  }

  @override
  Future<dynamic> getCameraPosition() async {
    return CameraPosition(
            controller.getCenter().toLatLng(), controller.getLevel())
        .toMessageable();
  }

  @override
  Future<void> hideOverlay(MapOverlay overlay) async {
    final mapTypeId = switch (overlay) {
      MapOverlay.bicycleRoad => 8,
      MapOverlay.roadviewLine => 5,
      MapOverlay.hillsading => 7,
      MapOverlay.hybrid => 3,
    };
    controller.removeOverlayMapTypeId(mapTypeId);
  }

  @override
  Future<void> moveCamera(CameraUpdate camera,
      {CameraAnimation? animation}) async {
    JSAny animationOption = {
      "animate": animation == null ? false : {"duration": animation.duration}
    }.jsify()!;
    final level = controller.getLevel();
    switch (camera.type) {
      case CameraUpdateType.newCenterPoint:
        final zoomLevel = camera.zoomLevel == -1
            ? level
            : _calculateZoomLevel(camera.zoomLevel);
        controller.jump(
            WebLatLng.fromLatLng(camera.position!), zoomLevel, animationOption);
        break;
      case CameraUpdateType.newCameraPos:
        final zoomLevel = camera.cameraPosition!.zoomLevel == -1
            ? level
            : _calculateZoomLevel(camera.cameraPosition!.zoomLevel);
        controller.jump(WebLatLng.fromLatLng(camera.cameraPosition!.position),
            zoomLevel, animationOption);
        break;
      case CameraUpdateType.zoomTo:
        final zoomLevel = camera.zoomLevel == -1
            ? level
            : _calculateZoomLevel(camera.zoomLevel);
        controller.setLevel(zoomLevel, {"options": animationOption}.jsify());
        break;
      case CameraUpdateType.zoomIn:
        controller.setLevel(level - 1, {"options": animationOption}.jsify());
        break;
      case CameraUpdateType.zoomOut:
        controller.setLevel(level + 1, {"options": animationOption}.jsify());
        break;
      case CameraUpdateType.newCameraAngle:
      case CameraUpdateType.rotate:
      case CameraUpdateType.tilt:
        break;
      case CameraUpdateType.fitMapPoints:
        final bounds = WebLatLngBound();
        camera.fitPoints!
            .map((e) => WebLatLng.fromLatLng(e))
            .forEach((e) => bounds.extend(e));
        controller.setBounds(bounds, camera.padding ?? 0, camera.padding ?? 0,
            camera.padding ?? 0, camera.padding ?? 0);
    }
  }

  @override
  Future<void> setGesture(GestureType gesture, bool enable) async {
    switch (gesture) {
      case GestureType.pan:
        controller.setDraggable(enable);
        break;
      case GestureType.oneFingerDoubleTap:
      case GestureType.twoFingerSingleTap:
      case GestureType.zoom:
        controller.setZoomable(enable);
        break;
      case GestureType.rotate:
      case GestureType.tilt:
      case GestureType.longTapAndDrag:
      case GestureType.rotateZoom:
      case GestureType.oneFingerZoom:
      case GestureType.unknown:
    }
  }

  @override
  Future<void> showOverlay(MapOverlay overlay) async {
    final mapTypeId = switch (overlay) {
      MapOverlay.bicycleRoad => 8,
      MapOverlay.roadviewLine => 5,
      MapOverlay.hillsading => 7,
      MapOverlay.hybrid => 3,
    };
    controller.addOverlayMapTypeId(mapTypeId);
  }

  @override
  Future<dynamic> toScreenPoint(LatLng position) async {
    final protection = controller.getProjection();
    return protection
        .containerPointFromCoords(WebLatLng.fromLatLng(position))
        .toPoint()
        .toMessageable();
  }

  @override
  Future<void> defaultGUIposition(
      DefaultGUIType type, MapGravity gravity, double x, double y) async {
    if (type != DefaultGUIType.compass &&
        gravity.verticalAlign == VerticalAlign.bottom) {
      final position = switch (gravity.horizontalAlign) {
        HorizontalAlign.left => 0,
        HorizontalAlign.center => -1,
        HorizontalAlign.right => 1,
      };
      if (position >= 0) {
        controller.setCopyrightPosition(position, false);
      }
    }
  }

  @override
  void onCameraMoveEnd(CameraPosition position, GestureType gestureType) {
    channel.invokeMethod("onCameraMoveEnd",
        {"gesture": gestureType.value, "position": position.toMessageable()});
  }

  @override
  void onCameraMoveStart(GestureType gestureType) {
    channel.invokeMethod("onCameraMoveStart", {"gesture": gestureType.value});
  }

  @override
  void onCompassClick() {
    channel.invokeMethod("onCompassClick");
  }

  @override
  void onLodPoiClick(String layerId, String poiId) {
    channel.invokeMethod("onLodPoiClick", {"layerId": layerId, "poiId": poiId});
  }

  @override
  void onMapClick(KPoint point, LatLng position) {
    channel.invokeMethod("onMapClick",
        {"point": point.toMessageable(), "position": position.toMessageable()});
  }

  @override
  void onMapDestroy() {
    channel.invokeMethod("onMapDestroy");
  }

  @override
  void onMapError(Error error) {
    if (error is KakaoAuthError) {
      channel.invokeMethod("onMapError", {
        "className": "KakaoAuthError",
        "message": error.message,
      });
    }
    if (error is KakaoMapError) {
      channel.invokeMethod("onMapError", {
        "className": error.className,
        "message": error.message,
      });
    }
  }

  @override
  void onMapPaused() {
    channel.invokeMethod("onMapPaused");
  }

  @override
  void onMapReady() {
    channel.invokeMethod("onMapReady");
  }

  @override
  void onMapResumed() {
    channel.invokeMethod("onMapResumed");
  }

  @override
  void onPoiClick(String layerId, String poiId) {
    channel.invokeMethod("onPoiClick", {"layerId": layerId, "poiId": poiId});
  }

  @override
  void onTerrainClick(KPoint point, LatLng position) {
    channel.invokeMethod("onMapClick",
        {"point": point.toMessageable(), "position": position.toMessageable()});
  }

  @override
  void onTerrainLongClick(KPoint point, LatLng position) {
    channel.invokeMethod("onMapClick",
        {"point": point.toMessageable(), "position": position.toMessageable()});
  }
}
