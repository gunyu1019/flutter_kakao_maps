part of '../../kakao_map_sdk.dart';

/// [Polyline] 또는 [Polygon]의 도형을 사각형으로 구성할 때 사용하는 객체입니다.
class RectanglePoint extends _BaseDotPoint {
  /// 사각형의 가로 길이입니다.
  final double width;

  /// 사각형의 세로 길이입니다.
  final double height;

  /// 도형을 구성할 때, 시계 방향으로 설정할 지 정의합니다.
  /// [addHole] 함수로 구멍을 구성할 때는 반시계 방향으로 정의해야하며,
  /// [clockwise]의 값을 false로 정의해야 합니다.
  final bool clockwise;

  RectanglePoint(
    this.width,
    this.height,
    super.basePoint, {
    this.clockwise = true,
  });

  RectanglePoint copyWith({
    double? width,
    double? height,
    LatLng? basePoint,
    bool? clockwise,
  }) {
    final point = RectanglePoint(
      width ?? this.width,
      height ?? this.height,
      basePoint ?? this.basePoint,
      clockwise: clockwise ?? this.clockwise,
    );
    point._holes.addAll(_holes);
    return point;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RectanglePoint &&
        other.width == width &&
        other.height == height &&
        other.basePoint == basePoint &&
        other.clockwise == clockwise &&
        listEquals(other._holes, _holes);
  }

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      basePoint.hashCode ^
      clockwise.hashCode ^
      _holes.hashCode;

  @override
  int get type => 1;

  @override
  PointShapeType get dotType => PointShapeType.rectangle;
}
