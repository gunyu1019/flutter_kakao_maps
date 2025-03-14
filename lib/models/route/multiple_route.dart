part of '../../kakao_map_sdk.dart';

/// 지도에 다중 선형([MultipleRoute])를 나타내는 객체입니다.
/// [MultipleRoute]는 지도에 선형의 경로(길찾기 라인)를 다양하게 표현합니다.
class MultipleRoute {
  final RouteController _controller;

  /// [MultipleRoute]의 고유 ID입니다.
  final String id;

  /// [MultipleRoute]에 적용된 곡선 유형입니다.
  final List<CurveType> _curveType;

  final List<List<LatLng>> _points;
  final List<int> _styleIndex;
  List<RouteStyle> _styles;

  bool _visible;

  /// [MultipleRoute]가 현재 지도에 그려지는지 여부를 나타냅니다.
  bool get visible => _visible;

  int _zOrder;

  /// [MultipleRoute]의 렌더링 우선순위입니다.
  int get zOrder => _zOrder;

  MultipleRoute._(this._controller, this.id,
      {required List<List<LatLng>> points,
      required List<RouteStyle> style,
      required List<CurveType> curveType,
      required List<int> styleIndex,
      required int zOrder})
      : _points = points,
        _styles = style,
        _curveType = curveType,
        _styleIndex = styleIndex,
        _visible = true,
        _zOrder = zOrder;

  /// [index]에 따라 단일 선형([Route]) 형태로 불러옵니다.
  /// 불러온 [Route] 객체에서 [Route.changeStyle], [Route.changePoint] 등의 수정을 할 수는 없습니다.
  Route getRoute(int index) => Route._fromMultiple(_controller, id, this,
      points: _points[index],
      style: _styles[_styleIndex[index]],
      curveType: _curveType[index]);

  /// [MultipleRoute]를 지도에서 보이도록 합니다.
  Future<void> show() async {
    await _controller._changeRouteVisible(id, true);
    _visible = true;
  }

  /// [MultipleRoute]를 지도에서 노출되지 않도록 합니다.
  Future<void> hide() async {
    await _controller._changeRouteVisible(id, false);
    _visible = false;
  }

  /// [MultipleRoute]에 정의된 스타일을 [index] 순에 따라 [RouteStyle] 형태로 불러옵니다.
  RouteStyle getStyle(int index) => _styles[_styleIndex[index]];

  /// [MultipleRoute]에 정의된 스타일을 [index] 순에 따라 정의된 선형의 지점을 불러옵니다.
  List<LatLng> getPoints(int index) => _points[index];

  /// [MultipleRoute]에 정의된 스타일을 [index] 순에 따라 정의된 선형의 곡선 유형([CurveType])을 불러옵니다.
  CurveType getCurveType(int index) => _curveType[index];

  /// [MultipleRoute] 개체를 삭제합니다.
  Future<void> remove() async {
    await _controller.removeMultipleRoute(this);
  }

  /// [index]에 따라 정의된 선형의 지점([points])을 다시 정의합니다.
  Future<void> changePoint(int index, List<LatLng> points) async {
    _points[index] = points;
    await _controller._changeRoute(id, _styles[0].id!, _curveType, _points);
  }

  /// [index]에 따라 정의된 선형의 곡선 유형([curveType])을 다시 정의합니다.
  Future<void> changeCurveType(int index, CurveType curveType) async {
    _curveType[index] = curveType;
    await _controller._changeRoute(id, _styles[0].id!, _curveType, _points);
  }

  /// [MultipleRoute]에서 사용하는 스타일([RouteStyle])을 다시 정의합니다.
  Future<void> changeStyle(List<RouteStyle> styles) async {
    if (styles.isEmpty) {
      throw Exception("styles parameter is empty.");
    }
    final styleId =
        styles[0].id ?? await _controller.manager.addMultipleRouteStyle(styles);
    await _controller._changeRoute(id, styleId, _curveType, _points);
    _styles = styles;
  }

  /// [MutlipleRoute]의 렌더링 우선순위를 다시 정의합니다.
  Future<void> setZOrder(int zOrder) async {
    await _controller._changeRouteZOrder(id, zOrder);
    _zOrder = zOrder;
  }
}
