part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.CustomOverlay")
extension type WebCustomOverlay._(JSObject _) implements JSObject {
  external WebCustomOverlay(WebCustomOverlayOption options);

  external void setMap(WebMapController? map);
  external WebMapController getMap();

  external void setPosition(WebLatLng position);
  external WebLatLng getPosition();

  external void setContent(web.Element content);
  external web.Element getContent();

  external void setVisible(bool visible);
  external bool getVisible();

  external void setZIndex(int zIndex);
  external int getZIndex();
}
