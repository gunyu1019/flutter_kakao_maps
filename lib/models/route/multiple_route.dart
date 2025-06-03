part of '../../kakao_map_sdk.dart';

/// 지도에 다중 선형([MultipleRoute])를 나타내는 객체입니다.
/// [MultipleRoute]는 지도에 선형의 경로(길찾기 라인)를 다양하게 표현합니다.
class MultipleRoute extends BaseRoute with BaseMultipleRoute {
  final List<RouteSegment> _segments;
  List<RouteStyle> _styles;

  @override
  final RouteController _controller;

  @override
  final String id;

  @override
  bool _visible;

  @override
  int _zOrder;

  @override
  List<RouteStyle> get styles => _styles;

  @override
  List<RouteSegment> get segments => _segments;

  @override
  bool get multiple => true;

  MultipleRoute._(this._controller, this.id,
      {required List<RouteStyle> styles,
      required List<RouteSegment> segments,
      required int zOrder})
      : _segments = segments,
        _styles = styles,
        _visible = true,
        _zOrder = zOrder {
    for (RouteSegment segment in _segments) {
      segment._setParent(this);
    }
  }

  /// [MultipleRoute]에서 사용하는 스타일([RouteStyle])을 다시 정의합니다.
  Future<void> changeStyle(List<RouteStyle> styles) async {
    if (styles.isEmpty) {
      throw Exception("styles parameter is empty.");
    }
    if (styles.any((e) => !e._isAdded)) {
      await _controller.manager.addMultipleRouteStyle(styles, styles.first.id);
    }
    await _controller._changeMultipleRoute(id, styles.first.id!, segments);
    _styles = styles;
  }
}
