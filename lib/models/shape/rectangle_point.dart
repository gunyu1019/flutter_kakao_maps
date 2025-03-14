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

  RectanglePoint(this.width, this.height, super.basePoint,
      {this.clockwise = true});

  @override
  Map<String, dynamic> toMessageable([bool isHole = false]) {
    final payload = <String, dynamic>{
      "type": type,
      "dotType": dotType.value,
      "width": width,
      "height": height,
      "clockwise": clockwise,
    };
    payload.addAll(super.toMessageable(isHole));
    return payload;
  }

  @override
  int get type => 1;

  @override
  PointShapeType get dotType => PointShapeType.rectangle;
}
