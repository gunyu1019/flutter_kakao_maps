part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.MapProjection")
extension type WebMapProjection._(JSObject _) implements JSObject {
  external WebPoint pointFromCoords(WebLatLng latlng);
  external WebLatLng coordsFromPoint(WebPoint point);

  external WebPoint containerPointFromCoords(WebLatLng latlng);
  external WebLatLng coordsFromContainerPoint(WebPoint point);
}
