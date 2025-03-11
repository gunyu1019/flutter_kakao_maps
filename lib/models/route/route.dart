part of '../../kakao_map_sdk.dart';

class Route {
  final RouteController _controller;
  final String id;

  List<LatLng> _points;
  List<LatLng> get points => _points;

  RouteStyle _style;
  RouteStyle get style => _style;

  CurveType _curveType;
  CurveType get curveType => _curveType;

  final bool _isMultiple;
  final MultipleRoute? parents;

  bool _visible;
  bool get visible => _visible;

  int _zOrder;
  int get zOrder => _zOrder;

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

  Future<void> show() async {
    if (_isMultiple) return;
    await _controller._changeRouteVisible(id, true);
    _visible = true;
  }

  Future<void> hide() async {
    if (_isMultiple) return;
    await _controller._changeRouteVisible(id, false);
    _visible = false;
  }

  Future<void> remove() async {
    if (_isMultiple) return;
    await _controller.removeRoute(this);
  }

  Future<void> changeStyle(RouteStyle style) async {
    if (_isMultiple) return;
    String styleId = style.id ?? await _controller.manager.addRouteStyle(style);
    await _controller._changeRoute(id, styleId, [_curveType], [_points]);
    _style = style;
  }

  Future<void> changeCurveType(CurveType curveType) async {
    if (_isMultiple) return;
    await _controller._changeRoute(id, style.id!, [curveType], [_points]);
    _curveType = curveType;
  }

  Future<void> changePoint(List<LatLng> points) async {
    if (_isMultiple) return;
    await _controller._changeRoute(id, style.id!, [_curveType], [points]);
    _points = points;
  }
}
