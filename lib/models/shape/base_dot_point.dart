part of '../../kakao_map_sdk.dart';

/// [Polygon] 또는 [Polygon]의 도형을 상대 좌표으로 구성할 때 사용하는 객체입니다.
/// 도형을 [basePoint]을 기준으로 좌표를 기준으로 도형을 생성합니다.
sealed class _BaseDotPoint extends BasePoint {
  /// 도형을 구성하는 기준 지점을 정의합니다. 도형을 구성할 때 필수로 필요한 값입니다.
  /// [addHole]을 이용하여 구멍을 구성하는 경우, [basePoint]를 정의할 필요는 없습니다.
  final LatLng basePoint;
  final List<_BaseDotPoint> _holes = [];

  _BaseDotPoint(this.basePoint);

  /// 도형에 구멍을 추가합니다.
  /// [hole.basePoint] 개체는 무시되며, [basePoint]을 기준으로 구멍을 생성합니다.
  void addHole(_BaseDotPoint hole) => _holes.add(hole);

  /// 도형에 [width]와 [height]를 가지고 있는 사각형의 구멍을 추가합니다.
  void addRetangleHole(double width, double height) =>
      _holes.add(RectanglePoint(width, height, _DUMMY_POINT, clockwise: false));

  /// 도형에 [radius]를 가지고 있는 원형의 구멍을 추가합니다.
  void addCircleHole(double radius) =>
      _holes.add(CirclePoint(radius, _DUMMY_POINT, clockwise: false));

  /// 도형에 구성한 구멍의 개수를 불러옵니다.
  int get holeCount => _holes.length;

  /// [_BaseDotPoint.addHole] 함수로 추가한 구멍을 [index] 순서에 따라 해당하는 객체를 불러옵니다.
  _BaseDotPoint? getHole(int index) => _holes[index];

  /// [_BaseDotPoint.addHole] 함수로 추가한 구멍을 [index] 순서에 따라 해당하는 객체를 삭제합니다.
  void removeHole(int index) => _holes.removeAt(index);

  @override
  Map<String, dynamic> toMessageable([bool isHole = false]) {
    final payload = <String, dynamic>{};
    if (!isHole) {
      payload["basePoint"] = basePoint.toMessageable();
      payload["holes"] = _holes.map((e) => e.toMessageable(true)).toList();
    }
    return payload;
  }

  @override
  int get type => 1;

  PointShapeType get dotType => PointShapeType.points;

  // ignore: constant_identifier_names
  static const _DUMMY_POINT = LatLng(0, 0);
}
