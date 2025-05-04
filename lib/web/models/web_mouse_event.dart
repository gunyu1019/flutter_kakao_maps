part of '../../kakao_map_sdk.dart';

extension type WebMouseEvent._(JSObject _) implements JSObject {
  external WebLatLng get latLng;
  external WebPoint get point;

  KPoint getPoint() => point.toPoint();
  LatLng getPosition() => latLng.toLatLng();
}
