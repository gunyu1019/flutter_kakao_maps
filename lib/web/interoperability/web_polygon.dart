part of '../../kakao_map_sdk.dart';

@JS("kakao.maps.Polygon")
extension type WebPolygon._(JSObject _) implements JSObject {
  external WebPolygon(WebPolygonOption options);

  external void setMap(WebMapController map);
  external WebMapController getMap();
  external void setOptions(WebPolygonOption options);
  external void setPath(List<WebLatLng> path);
  external List<WebLatLng> getPath();
  external double getLength();
  external double getArea();
  external void setZIndex(int zIndex);
  external int getZIndex();
}
