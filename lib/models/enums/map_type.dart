part of '../../kakao_map_sdk.dart';

/// 지도를 구성하는 유형입니다.
enum MapType {
  /// 일반 지도
  normal(value: "map"),

  /// 위성 지도
  skyview(value: "skyview");

  final String value;

  const MapType({required this.value});
}
