part of '../../../kakao_map_sdk.dart';

/// [CirclePoint], [RectanglePoint] 등의 [_BaseDotPoint] 형태의 도형 지점을 구성하는 유형입니다.
enum PointShapeType {
  /// 원형
  circle(0),

  /// 사각형
  rectangle(1),

  /// 좌표
  points(2),
  none(-1);

  final int value;

  const PointShapeType(this.value);
}
