part of '../kakao_map_sdk_web.dart';

extension type WebCustomOverlayOption._(JSObject _) implements JSObject {
  external WebCustomOverlayOption(
      {bool clickable,
      web.Element content,
      WebMapController map,
      WebLatLng position,
      double xAnchor = 0.5,
      double yAnchor = 0.5,
      int zIndex = 10001});
}
