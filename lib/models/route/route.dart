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

  /// [Route]의 지점입니다.
  List<LatLng> get points => _points;

  RouteStyle _style;

  /// [Route]에 정의된 [RouteStyle] 스타일 객체입니다.
  RouteStyle get style => _style;

  CurveType _curveType;

  /// [Route]의 곡선 유형을 불러옵니다.
  CurveType get curveType => _curveType;

  final bool _isMultiple;

  /// [MultipleRoute.getRoute]으로 단일 선형을 불러온 경우,
  /// 단일 선형이 속해있는 다중 선형을 불러옵니다.
  /// 만약 다중 선형으로 정의된 객체가 아닌 경우 null을 반환합니다.
  final MultipleRoute? parents;

  Route._(this._controller, this.id,
      {required List<LatLng> points,
      required RouteStyle style,
      required CurveType curveType,
      required int zOrder})
      : _points = points,
        _style = style,
        _curveType = curveType,
        _isMultiple = false,
        _visible = true,
        parents = null,
        _zOrder = zOrder;

  Route._fromMultiple(this._controller, this.id, this.parents,
      {required List<LatLng> points,
      required RouteStyle style,
      required CurveType curveType})
      : _points = points,
        _style = style,
        _curveType = curveType,
        _visible = true,
        _isMultiple = true,
        _zOrder = parents!._zOrder;

  /// 선형([Route]) 정의된 스타일([RouteStyle])을 다시 정의합니다.
  Future<void> changeStyle(RouteStyle style) async {
    if (_isMultiple) return;
    String styleId = style.id ?? await _controller.manager.addRouteStyle(style);
    await _controller._changeRoute(id, styleId, [_curveType], [_points]);
    _style = style;
  }

  /// 선형([Route]) 정의된 곡선 유형([CurveType])을 다시 정의합니다.
  Future<void> changeCurveType(CurveType curveType) async {
    if (_isMultiple) return;
    await _controller._changeRoute(id, style.id!, [curveType], [_points]);
    _curveType = curveType;
  }

  /// 선형([Route]) 정의된 지점을 다시 정의합니다.
  Future<void> changePoint(List<LatLng> points) async {
    if (_isMultiple) return;
    await _controller._changeRoute(id, style.id!, [_curveType], [points]);
    _points = points;
  }
}
