part of '../../kakao_map_sdk.dart';

@JS("kakao.maps.Point")
extension type WebPoint._(JSObject _) implements JSObject {
  external WebPoint(double x, double y);

  external double get x;
  external double get y;
}
