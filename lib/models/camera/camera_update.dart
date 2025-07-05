part of '../../kakao_map_sdk.dart';

/// 지도의 카메라의 위치를 새롭게 정의할 때 사용하는 객체입니다.
class CameraUpdate with KMessageable {
  final CameraUpdateType type;
  final LatLng? position;
  final int zoomLevel;

  // CameraUpdateType.newCameraPos
  final CameraPosition? cameraPosition;

  // For CameraUpdateType.rotate, CameraUpdateType.tilt
  final double angle;

  // For CameraUpdateType.fitMapPoints
  final List<LatLng>? fitPoints;
  final int? padding;

  CameraUpdate._(
    this.type, {
    this.position,
    this.zoomLevel = -1,
    this.cameraPosition,
    this.angle = -1.0,
    this.fitPoints,
    this.padding,
  });

  /// 카메라가 새롭게 이동할 위치를 지정합니다.
  ///
  /// @params position 새롭게 이동할 카메라의 좌표 값입니다.
  /// @params zoomLevel 새롭게 지정할 확대/축솟 값입니다. (선택 값입니다.)
  factory CameraUpdate.newCenterPosition(LatLng position, {int? zoomLevel}) =>
      CameraUpdate._(CameraUpdateType.newCenterPoint,
          position: position, zoomLevel: zoomLevel ?? -1);

  /// [CameraPosition] 객체로 카메라가 이동할 위치를 설정합니다.
  ///
  /// @params cameraPosition [CameraPosition] 카메라의 위치가 담긴 객체입니다.
  factory CameraUpdate.newCameraPos(CameraPosition cameraPosition) =>
      CameraUpdate._(CameraUpdateType.newCameraPos,
          cameraPosition: cameraPosition);

  /// 카메라의 줌레벨을 [zoomLevel]에 따라 확대 또는 축소를 합니다.
  factory CameraUpdate.zoomTo(int zoomLevel) =>
      CameraUpdate._(CameraUpdateType.zoomTo, zoomLevel: zoomLevel);

  /// 카메라가 더 자세한 정보를 담아낼 수 있도록, 한 단계 확대합니다.
  factory CameraUpdate.zoomIn() => CameraUpdate._(CameraUpdateType.zoomIn);

  /// 카메라가 더 넓은 정보를 담아낼 수 있도록, 한 단계 축소합니다.
  factory CameraUpdate.zoomOut() => CameraUpdate._(CameraUpdateType.zoomOut);

  /// 카메라를 [angle] 각도만큼 따라 회전합니다.
  factory CameraUpdate.rotate(double angle) =>
      CameraUpdate._(CameraUpdateType.rotate, angle: angle);

  /// 카메라를 [angle] 각도만큼 기울기 각도를 수정합니다.
  factory CameraUpdate.tilt(double angle) =>
      CameraUpdate._(CameraUpdateType.tilt, angle: angle);

  /// [fitPoints]에 주어진 위치(좌표)들이 화면의 가장자리에 맞춰 보여지도록 카메라의 위치를 변경합니다.
  factory CameraUpdate.fitMapPoints(List<LatLng> fitPoints,
          {int? padding, int? zoomLevel}) =>
      CameraUpdate._(CameraUpdateType.fitMapPoints,
          fitPoints: fitPoints, padding: padding, zoomLevel: zoomLevel ?? -1);

  factory CameraUpdate.fromMessageable(dynamic payload) {
    final type =
        CameraUpdateType.values.firstWhere((e) => e.value == payload['type']);
    final angle = payload["angle"];
    final zoomLevel = payload["zoomLevel"];
    final position =
        payload.containsKey("latitude") && payload.containsKey("longitude")
            ? LatLng.fromMessageable(payload)
            : null;
    return switch (type) {
      CameraUpdateType.newCenterPoint =>
        CameraUpdate.newCenterPosition(position!, zoomLevel: zoomLevel),
      CameraUpdateType.newCameraPos => () {
          final cameraPosition = CameraPosition.fromMessageable(payload);
          return CameraUpdate.newCameraPos(cameraPosition);
        }(),
      CameraUpdateType.newCameraAngle => throw UnimplementedError(),
      CameraUpdateType.zoomTo => CameraUpdate.zoomTo(zoomLevel),
      CameraUpdateType.zoomIn => CameraUpdate.zoomIn(),
      CameraUpdateType.zoomOut => CameraUpdate.zoomOut(),
      CameraUpdateType.rotate => CameraUpdate.rotate(angle),
      CameraUpdateType.tilt => CameraUpdate.tilt(angle),
      CameraUpdateType.fitMapPoints => CameraUpdate.fitMapPoints(
          payload['points'].map<LatLng>(LatLng.fromMessageable).toList(),
          padding: payload["padding"],
          zoomLevel: zoomLevel)
    };
  }

  @override
  Map<String, dynamic> toMessageable() {
    Map<String, dynamic> payload = {"type": type.value};
    switch (type) {
      case CameraUpdateType.newCenterPoint:
        payload.addAll(position!.toMessageable());
      case CameraUpdateType.zoomTo:
        payload['zoomLevel'] = zoomLevel;
        break;
      case CameraUpdateType.newCameraPos:
        payload.addAll(cameraPosition!.toMessageable());
        break;
      case CameraUpdateType.newCameraAngle: // Nothing payload.
      case CameraUpdateType.zoomIn:
      case CameraUpdateType.zoomOut:
        break;
      case CameraUpdateType.rotate:
      case CameraUpdateType.tilt:
        payload['angle'] = angle;
        break;
      case CameraUpdateType.fitMapPoints:
        payload['points'] =
            fitPoints!.map((latlng) => latlng.toMessageable()).toList();
        payload['padding'] = padding ?? 0;
        payload['zoomLevel'] = zoomLevel;
        break;
    }
    return payload;
  }
}
