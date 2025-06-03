part of '../../kakao_map_sdk.dart';

/// 지도에 원, 삼각형, 사각형 등의 닫힌 도형을 나타내는 객체입니다.
class Polygon<T extends BasePoint> {
  final ShapeController _controller;

  /// [Polygon]의 고유 ID입니다.
  final String id;

  PolygonStyle _style;

  /// [Polygon]에 정의된 [PolygonStyle] 스타일 객체입니다.
  PolygonStyle get style => _style;

  T _position;

  /// [Polygon]에 정의된 위치를 나타냅니다.
  T get position => _position;

  bool _visible;

  /// [Polygon]가 현재 지도에 그려지는지 여부를 나타냅니다.
  bool get visible => _visible;

  Polygon._(ShapeController controller, this.id,
      {required T position, required PolygonStyle style})
      : _controller = controller,
        _style = style,
        _position = position,
        _visible = true;

  /// 도형에 정의된 스타일([PolygonStyle])을 다시 정의합니다.
  Future<void> changeStyle(PolygonStyle style) async {
    if (!style._isAdded) {
      await _controller.manager.addPolygonShapeStyle(style);
    }
    await _controller._changePolygon(id, _position, style.id!);
    _style = style;
  }

  /// [Polygon]을 지도에서 삭제합니다..
  Future<void> remove() async {
    await _controller.removePolygonShape(this);
  }

  /// 도형에 정의된 위치를 다시 정의합니다.
  /// 이 경우 객체는 유지하지만 도형을 [position] 매개변수에 따라 다시 그리게됩니다.
  /// 다른 형태의 도형을 구성하려고 한다면 새롭게 만드는 것을 권장한다.
  Future<void> changePosition(T position) async {
    await _controller._changePolygon(id, position, style.id!);
    _position = position;
  }

  /// [Polygon]를 지도에서 보이도록 합니다.
  Future<void> show() async {
    await _controller._changePolygonVisible(id, true);
    _visible = true;
  }

  /// [Polygon]를 지도에서 보이도록 합니다.
  Future<void> hide() async {
    await _controller._changePolygonVisible(id, false);
    _visible = false;
  }
}
