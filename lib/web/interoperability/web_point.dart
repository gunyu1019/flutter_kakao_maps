part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.Point")
extension type WebPoint._(JSObject _) implements JSObject {
  external WebPoint(double x, double y);

  external double get x;
  external double get y;

  factory WebPoint.fromPoint(KPoint payload) =>
      WebPoint(payload.x.toDouble(), payload.y.toDouble());

  KPoint toPoint() => KPoint(x, y);
}
