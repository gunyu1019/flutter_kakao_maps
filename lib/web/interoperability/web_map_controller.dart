part of '../../kakao_map_sdk.dart';


@JS("kakao.maps.Map")
extension type WebMapController._(JSObject _) implements JSObject {
  external WebMapController(web.Element element, WebMapOption option);

  external void setCenter(WebLatLng latlng);
  external WebLatLng getCenter();

  external int getMapTypeId();

  external void setLevel(int level);
  external int getLevel();

  external void setBounds(WebLatLngBound bounds, [int paddingTop, int paddingRight, int paddingBottom, int paddingLeft]);
  external WebLatLngBound getBounds();
}