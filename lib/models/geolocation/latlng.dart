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

  /// [other]간 거리를 구합니다.
  /// Kakao Map SDK에서 두 지점간 거리를 구하는 방법은 성능을 고려하여 Haversine Formula를 이용합니다.
  /// 따라서 1~2%의 오차를 가지고 있을 수도 있습니다.
  double distance(LatLng other) => _haversine(this, other);

  /// 현 좌표에서 [degrees] 방향으로 [distacne](m)만큼 떨어진 거리를 새로운 좌표를 구합니다.
  LatLng offset(double distance, double degrees) =>
      _pointOffset(this, distance, degrees);
}
