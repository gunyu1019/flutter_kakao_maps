part of '../kakao_map_sdk_web.dart';

@JS("kakao.maps.LatLng")
extension type WebLatLng._(JSObject _) implements JSObject {
  external WebLatLng(double latitude, double longitude);

  factory WebLatLng.fromLatLng(LatLng payload) =>
      WebLatLng(payload.latitude, payload.longitude);

  factory WebLatLng.fromMessageable(dynamic payload) =>
      WebLatLng.fromLatLng(LatLng.fromMessageable(payload));

  external double getLat();
  external double getLng();

  LatLng toLatLng() => LatLng(getLat(), getLng());

  dynamic toMessageable() => LatLng(getLat(), getLng()).toMessageable();
}
