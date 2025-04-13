part of '../../kakao_map_sdk.dart';

/// 위도(Latitude)와 경도(longitude)를 사용하여 좌표를 나타내는 객체입니다.
class LatLng with KMessageable {
  /// 위도
  final double latitude;

  /// 경도
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  factory LatLng.fromMessageable(dynamic payload) =>
      LatLng(payload['latitude'], payload['longitude']);

  @override
  Map<String, dynamic> toMessageable() =>
      {"latitude": latitude, "longitude": longitude};
}
