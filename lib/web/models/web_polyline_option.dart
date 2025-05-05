part of '../kakao_map_sdk_web.dart';

extension type WebPolylineOption._(JSObject _) implements JSObject {
  external WebPolylineOption(
      {bool endArrow,
      JSArray<WebLatLng> path,
      double strokeWeight = 3,
      String strokeColor,
      double strokeOpacity = 0.6,
      String strokeStyle = "solid",
      int zIndex = 10000});

  external bool get endArrow;
  external JSArray<WebLatLng> get path;
  external double get strokeWeight;
  external String get strokeColor;
  external double get strokeOpacity;
  external String get strokeStyle;
  external int get zIndex;

  external set endArrow(bool value);
  external set path(JSArray<WebLatLng> value);
  external set strokeWeight(double value);
  external set strokeColor(String value);
  external set strokeOpacity(double value);
  external set strokeStyle(String value);
  external set zIndex(int value);
}
