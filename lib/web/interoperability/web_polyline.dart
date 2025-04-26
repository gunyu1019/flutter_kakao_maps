part of '../../kakao_map_sdk.dart';

@JS("kakao.maps.Polyline")
extension type WebPolyline._(JSObject _) implements JSObject {
  external WebPolyline(WebPolygonOption options);

  external void setMap(WebMapController map);
  external WebMapController getMap();
  external void setOptions(WebPolygonOption options);
  external void setPath(List<WebLatLng> path);
  external List<WebLatLng> getPath();
  external double getLength();
  external void setZIndex(int zIndex);
  external int getZIndex();
}
