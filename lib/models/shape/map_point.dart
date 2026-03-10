part of '../../kakao_map_sdk.dart';

/// [Polygon] 또는 [Polygon]의 도형을 절대 좌표으로 구성할 때 사용하는 객체입니다.
/// 도형을 위.경도([LatLng])를 기준으로 도형을 생성합니다.
class MapPoint extends BasePoint {
  final List<LatLng> points;
  final List<List<LatLng>> _holes = [];

  MapPoint(this.points);

  MapPoint copyWith({List<LatLng>? points, List<List<LatLng>>? holes}) {
    final point = MapPoint(points ?? this.points);
    point._holes.addAll(holes ?? _holes);
    return point;
  }

  bool _holesEquals(List<List<LatLng>> other) {
    if (_holes.length != other.length) return false;
    for (var i = 0; i < _holes.length; i++) {
      if (!listEquals(_holes[i], other[i])) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapPoint &&
        listEquals(other.points, points) &&
        _holesEquals(other._holes);
  }

  @override
  int get hashCode => points.hashCode ^ _holes.hashCode;

  /// 도형에 구멍을 추가합니다.
  void addHole(List<LatLng> hole) => _holes.add(hole);

  /// 도형에 구성한 구멍의 개수를 불러옵니다.
  int get holeCount => _holes.length;

  /// [MapPoint.addHole] 함수로 추가한 구멍을 [index] 순서에 따라 해당하는 객체를 불러옵니다.
  List<LatLng>? getHole(int index) => _holes[index];

  /// [MapPoint.addHole] 함수로 추가한 구멍을 [index] 순서에 따라 해당하는 객체를 삭제합니다.
  void removeHole(int index) => _holes.removeAt(index);

  @override
  Map<String, dynamic> toMessageable() {
    return <String, dynamic>{
      "type": type, // point type
      "points": points.map((e) => e.toMessageable()).toList(),
      "holes": _holes
          .map((e1) => e1.map((e2) => e2.toMessageable()).toList())
          .toList(),
    };
  }

  @override
  int get type => 0;
}
