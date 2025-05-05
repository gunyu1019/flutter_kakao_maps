part of '../kakao_map_sdk_web.dart';

extension type WebPolygonOption._(JSObject _) implements JSObject {
  external WebPolygonOption(
      {JSArray<JSArray<WebLatLng>> path,
      String fillColor,
      double fillOpacity = 0,
      String strokeColor,
      double strokeWeight = 3,
      double strokeOpacity = 0.6,
      String strokeStyle = "solid",
      int zIndex = 10000});

  external JSArray<JSArray<WebLatLng>> get path;
  external String get fillColor;
  external double get fillOpacity;
  external String get strokeColor;
  external double get strokeWeight;
  external double get strokeOpacity;
  external String get strokeStyle;
  external int get zIndex;

  external set path(JSArray<JSArray<WebLatLng>> value);
  external set fillColor(String value);
  external set fillOpacity(double value);
  external set strokeColor(String value);
  external set strokeWeight(double value);
  external set strokeOpacity(double value);
  external set strokeStyle(String value);
  external set zIndex(int value);
}
