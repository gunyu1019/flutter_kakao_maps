part of '../../kakao_map_sdk.dart';

/// 지도에 선형으로 구성된 도형을 나타내는 객체입니다.
class Polyline<T extends BasePoint> extends Shape {
  @override
  final BaseShapeController _controller;

  @override
  final String id;

  PolylineStyle _style;

  /// [Polyline]에 정의된 [PolylineStyle] 스타일 객체입니다.
  PolylineStyle get style => _style;

  T _position;

  /// [Polyline]에 정의된 위치를 나타냅니다.
  T get position => _position;

  bool _visible;

  /// [Polyline]가 현재 지도에 그려지는지 여부를 나타냅니다.
  bool get visible => _visible;

  PolylineCap _polylineCap;

  /// [Polyline]에서 정의된 끝모양을 불러옵니다.
  PolylineCap get polylineCap => _polylineCap;

  Polyline._(
    BaseShapeController controller,
    this.id, {
    required T position,
    required PolylineStyle style,
    required PolylineCap polylineCap,
  })  : _controller = controller,
        _style = style,
        _position = position,
        _polylineCap = polylineCap,
        _visible = true;

  /// 도형에 정의된 스타일([PolylineStyle])을 다시 정의합니다.
  Future<void> changeStyle(
    PolylineStyle style,
    PolylineCap? polylineCap,
  ) async {
    _polylineCap = polylineCap ?? _polylineCap;
    if (!style._isAdded) {
      await _controller.manager.addPolylineShapeStyle(style, _polylineCap);
    }
    await _controller._changePolyline(id, _position, style.id!);
    _style = style;
  }

  /// 도형에 정의된 위치를 다시 정의합니다.
  /// 이 경우 객체는 유지하지만 도형을 [position] 매개변수에 따라 다시 그리게됩니다.
  /// 다른 형태의 도형을 구성하려고 한다면 새롭게 만드는 것을 권장한다.
  Future<void> changePosition(T position) async {
    await _controller._changePolyline(id, position, style.id!);
    _position = position;
  }

  @override
  Future<void> remove() async {
    await _controller.removePolylineShape(this);
  }

  @override
  Future<void> show() async {
    await _controller._changePolylineVisible(id, true);
    _visible = true;
  }

  @override
  Future<void> hide() async {
    await _controller._changePolylineVisible(id, false);
    _visible = false;
  }
}
