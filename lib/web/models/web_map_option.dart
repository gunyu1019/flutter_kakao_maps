part of '../kakao_map_sdk_web.dart';

extension type WebMapOption._(JSObject _) implements JSObject {
  external WebMapOption(
      {required WebLatLng center,
      int level = 3,
      int mapTypeId = 1,
      bool draggable = true,
      bool scrollwheel = true,
      bool disableDoubleClick = true,
      bool disableDoubleClickZoom = true,
      String? projectionId = "0",
      bool titleAnimation = true,
      bool keyboardShortcuts = false});

  factory WebMapOption.fromMapOption(KakaoMapOption option) => WebMapOption(
      center: WebLatLng.fromLatLng(option.position),
      level: _calculateZoomLevel(option.zoomLevel),
      mapTypeId: option.mapType.value == "skyview" ? 2 : 1);

  factory WebMapOption.fromMessageable(dynamic payload) => WebMapOption(
      center: WebLatLng.fromMessageable(payload),
      level: _calculateZoomLevel(payload['zoomLevel'] as int),
      mapTypeId: payload['mapType'] == "skyview" ? 2 : 1);

  external WebLatLng get center;
  external int get level;
  external int get mapTypeId;
  external bool get draggable;
  external bool get scrollwheel;
  external bool get disableDoubleClick;
  external bool get disableDoubleClickZoom;
  external String? get projectionId;
  external bool get titleAnimation;
  external JSAny get keyboardShortcuts;
}
