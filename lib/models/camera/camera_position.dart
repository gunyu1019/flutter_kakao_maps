part of '../../kakao_map_sdk.dart';

/// 지도의 카메라 속성을 가지고 있는 객체입니다.
class CameraPosition with KMessageable {
  /// 지도를 비추고 있는 카메라의 중심 위치를 가져옵니다.
  final LatLng position;

  /// 지도의 비추고 있는 카메라의 확대/축소 값을 가져옵니다.
  final int zoomLevel;

  /// 지도를 비추고 있는 카메라의 기울기 각도를 가져옵니다.
  final double? tiltAngle;

  /// 지도를 비추고 있는 카메라의 회전 각도를 가져옵니다.
  final double? rotationAngle;

  /// 지도를 비추고 있는 카메라의 높이를 가져옵니다.
  final double? height;

  const CameraPosition(
    this.position,
    this.zoomLevel, {
    this.tiltAngle,
    this.rotationAngle,
    this.height,
  });

  factory CameraPosition.fromMessageable(dynamic payload) => CameraPosition(
        LatLng.fromMessageable(payload),
        payload['zoomLevel'],
        tiltAngle: payload['tiltAngle'],
        rotationAngle: payload['rotationAngle'],
        height: payload['height'],
      );

  @override
  Map<String, dynamic> toMessageable() {
    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "zoomLevel": zoomLevel,
      "tiltAngle": tiltAngle ?? 0.0,
      "rotationAngle": rotationAngle ?? 0.0,
      "height": height ?? -1.0,
    };
  }

  CameraPosition copyWith({
    LatLng? position,
    int? zoomLevel,
    double? tiltAngle,
    double? rotationAngle,
  }) =>
      CameraPosition(
        position ?? this.position,
        zoomLevel ?? this.zoomLevel,
        tiltAngle: tiltAngle ?? this.tiltAngle,
        rotationAngle: rotationAngle ?? this.rotationAngle,
      );

  @override
  int get hashCode =>
      position.hashCode ^
      zoomLevel.hashCode ^
      tiltAngle.hashCode ^
      rotationAngle.hashCode ^
      height.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraPosition &&
        other.position == position &&
        other.zoomLevel == zoomLevel &&
        other.tiltAngle == tiltAngle &&
        other.rotationAngle == rotationAngle &&
        other.height == height;
  }
}
