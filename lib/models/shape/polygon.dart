part of '../../kakao_map_sdk.dart';

class Polygon<T extends BasePoint> {
  final ShapeController _controller;
  final String id;

  PolygonStyle _style;
  PolygonStyle get style => _style;

  T _position;
  T get position => _position;

  bool _visible;
  bool get visible => _visible;

  Polygon._(ShapeController controller, this.id,
      {required T position, required PolygonStyle style})
      : _controller = controller,
        _style = style,
        _position = position,
        _visible = true;

  Future<void> changeStyle(PolygonStyle style) async {
    final styleId =
        style.id ?? await _controller.manager.addPolygonShapeStyle(style);
    await _controller._changePolygon(id, _position, styleId);
    _style = style;
  }

  Future<void> changePosition(T position) async {
    await _controller._changePolygon(id, position, style.id!);
    _position = position;
  }

  Future<void> show() async {
    await _controller._changePolygonVisible(id, true);
    _visible = true;
  }

  Future<void> hide() async {
    await _controller._changePolygonVisible(id, false);
    _visible = false;
  }
}
