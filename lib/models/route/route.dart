part of '../../kakao_map_sdk.dart';

/// 지도에 선형([Route])를 나타내는 객체입니다.
/// [Route]는 선형의 경로(길찾기 라인)를 지도에 나타냅니다.
class Route extends BaseRoute {
  @override
  final RouteController _controller;

  @override
  final String id;

  @override
  bool _visible;

  @override
  int _zOrder;

  List<LatLng> _points;

  @override
  bool get multiple => false;

  /// [Route]의 지점입니다.
  List<LatLng> get points => _points;

  RouteStyle _style;

  /// [Route]에 정의된 [RouteStyle] 스타일 객체입니다.
  RouteStyle get style => _style;

  CurveType _curveType;

  /// [Route]의 곡선 유형을 불러옵니다.
  CurveType get curveType => _curveType;

  Route._(this._controller, this.id,
      {required List<LatLng> points,
      required RouteStyle style,
      required CurveType curveType,
      required int zOrder})
      : _points = points,
        _style = style,
        _curveType = curveType,
        _visible = true,
        _zOrder = zOrder;

  /// 선형([Route]) 정의된 스타일([RouteStyle])을 다시 정의합니다.
  Future<void> changeStyle(RouteStyle style) async {
    if (!style._isAdded) {
      await _controller.manager.addRouteStyle(style);
    }
    await _controller._changeRoute(id, style.id!, _curveType, _points);
    _style = style;
  }

  /// 선형([Route]) 정의된 곡선 유형([CurveType])을 다시 정의합니다.
  Future<void> changeCurveType(CurveType curveType) async {
    await _controller._changeRoute(id, style.id!, curveType, _points);
    _curveType = curveType;
  }

  /// 선형([Route]) 정의된 지점을 다시 정의합니다.
  Future<void> changePoint(List<LatLng> points) async {
    await _controller._changeRoute(id, style.id!, _curveType, points);
    _points = points;
  }
}
