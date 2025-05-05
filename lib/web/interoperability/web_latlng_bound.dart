part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.LatLngBounds")
extension type WebLatLngBound._(JSObject _) implements JSObject {
  external WebLatLngBound([WebLatLng sw, WebLatLng ne]);

  external WebLatLng getSouthWest();
  external WebLatLng getNorthEast();

  external bool isEmpty();
  external void extend(WebLatLng latlng);
  external bool contain(WebLatLng latlng);
}
