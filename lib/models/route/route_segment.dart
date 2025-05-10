part of '../../kakao_map_sdk.dart';

/// [MultipleRoute]을 구성하는 선형의 요소입니다.
class RouteSegment with KMessageable {
  /// [MultipleRoute]의 고유 ID입니다. 등록되지 않았을 경우에는 null을 반환합니다.
  String? id;

  /// [RouteSegment]에서 정의한 선형이 [styleIndex] 번째 [RouteStyle]을 사용하는 지 반환합니다.
  int styleIndex;

  /// [RouteSegment]의 지점입니다.
  List<LatLng> points;

  /// [RouteSegment]의 곡선 구성입니다.
  CurveType curveType;

  /// [RouteSegment]을 구성하는 부모 객체입니다.
  /// 객체가 등록되지 않았다면 [MultipleRouteOption]을 반환하고,
  /// [RouteController.addMultipleRoute]에 의해 등록되었다면 [MultipleRoute]를 반환합니다.
  BaseMultipleRoute parent;

  RouteController? _controller;

  RouteSegment._(this.points, this.styleIndex, this.curveType, this.parent);

  /// [RouteSegment]를 구성하는 스타일을 반환합니다.
  RouteStyle get style => parent.styles[styleIndex];

  bool _isAdded() => _controller != null && id != null;

  void _setParent(MultipleRoute route) {
    parent = route;
    _controller = route._controller;
    id = route.id;
  }

  @override
  Map<String, dynamic> toMessageable() {
    return <String, dynamic>{
      "points": points.map((e) => e.toMessageable()).toList(),
      "curveType": curveType.value,
      "styleIndex": styleIndex,
    };
  }

  factory RouteSegment.fromMessageable(
          dynamic payload, BaseMultipleRoute parent) =>
      RouteSegment._(
          payload["points"].map<LatLng>(LatLng.fromMessageable).toList(),
          payload["styleIndex"],
          CurveType.values.firstWhere((e) => e.value == payload["curveType"]),
          parent);

  /// 선형의 지점([points])을 다시 정의합니다.
  Future<void> changePoint(List<LatLng> points) async {
    if (!_isAdded()) return;
    this.points = points;
    await _controller!
        ._changeMultipleRoute(id!, parent.styles[0].id!, parent.segments);
  }

  /// 선형의 곡선 유형([curveType])을 다시 정의합니다.
  Future<void> changeCurveType(int index, CurveType curveType) async {
    if (!_isAdded()) return;
    this.curveType = curveType;
    await _controller!
        ._changeMultipleRoute(id!, parent.styles[0].id!, parent.segments);
  }
}
