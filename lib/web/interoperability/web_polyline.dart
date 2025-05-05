part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.Polyline")
extension type WebPolyline._(JSObject _) implements JSObject {
  external WebPolyline(WebPolylineOption options);

  external void setMap(WebMapController? map);
  external WebMapController getMap();
  external void setOptions(WebPolylineOption options);
  external void setPath(JSArray<WebLatLng> path);
  external JSArray<WebLatLng> getPath();
  external double getLength();
  external void setZIndex(int zIndex);
  external int getZIndex();
}
