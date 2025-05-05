part of '../kakao_map_sdk_web.dart';

mixin KakaoMapWebControllerHandler {
  Future<dynamic> getCameraPosition();

  Future<void> moveCamera(
      CameraUpdate camera, {CameraAnimation? animation});

  Future<void> setGesture(GestureType gesture, bool enable);

  Future<void> setEventTrigger(int event);

  Future<dynamic> fromScreenPoint(int x, int y);

  Future<dynamic> toScreenPoint(LatLng position);

  Future<void> clearCache();

  Future<void> clearDiskCache();

  Future<bool> canShowPosition(int zoomLevel, List<LatLng> position);

  Future<void> changeMapType(MapType mapType);

  Future<void> hideOverlay(MapOverlay overlay);

  Future<void> showOverlay(MapOverlay overlay);

  Future<double> getBuildingHeightScale();

  // Future<void> setBuildingHeightScale(double scale);

  // Future<void> defaultGUIvisible(DefaultGUIType type, bool visible);

  Future<void> defaultGUIposition(
      DefaultGUIType type, MapGravity gravity, double x, double y);

  // Future<void> scaleAutohide(bool autohide);

  // Future<void> scaleAnimationTime(int fadeIn, int fadeOut, int retention);
}
