part of '../../kakao_map_sdk.dart';


extension type WebMapOption._(JSObject _) implements JSObject  {
  external WebMapOption({
    required WebLatLng center,
    int level = 3,
  });

  external WebLatLng get center;
  external int get level;
}