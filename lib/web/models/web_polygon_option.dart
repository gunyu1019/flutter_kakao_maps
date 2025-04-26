part of '../../kakao_map_sdk.dart';

extension type WebPolygonOption._(JSObject _) implements JSObject {
  external WebPolygonOption(
      {List<List<WebLatLng>> path,
      String fillColor,
      double fillOpacity = 0,
      String strokeColor,
      double strokeWeight = 3,
      double strokeOpacity = 0.6,
      String strokeStyle = "solid",
      int zIndex = 10000});
}
