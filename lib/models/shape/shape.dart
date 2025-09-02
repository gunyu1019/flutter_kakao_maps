part of '../../kakao_map_sdk.dart';

/// [Polygon], [Polyline]을 구성하는 기본 객체입니다.
abstract class Shape {
  abstract final BaseShapeController _controller;

  /// [Polygon] 또는 [Polyline]에서 사용하는 고유한 ID입니다.
  abstract final String id;

  /// [Polygon], [Polyline]를 지도에서 삭제합니다.
  Future<void> remove();

  /// [Polygon], [Polyline]를 지도에서 보이도록 합니다.
  Future<void> show();

  /// [Polygon], [Polyline]를 지도에서 보이지 않도록 합니다.
  Future<void> hide();
}
