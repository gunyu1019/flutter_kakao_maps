part of '../../kakao_map_sdk.dart';

/// 지도에 [PolylineText]를 나타내는 객체입니다.
/// [PolylineText]는 구부러진 글씨 또는 호르는 글씨를 지도에 표현하는 오버레이입니다.
class PolylineText {
  final LabelController _controller;

  /// [PolylineText]의 고유 ID입니다.
  final String id;

  /// [PolylineText]를 나타내는 지점(좌표)입니다.
  final List<LatLng> points;

  PolylineTextStyle _style;

  /// [PolylineText]에 정의된 [PolylineTextStyle] 객체입니다.
  /// [PolylineText]의 스타일을 정의합니다.
  PolylineTextStyle get style => _style;

  String _text;

  /// [PolylineText]에 표시되는 텍스트입니다.
  String get text => _text;

  bool _visible;

  /// [PolylineText]가 현재 지도에 그려지는 여부를 나타냅니다.
  bool get visible => _visible;

  PolylineText._(this._controller, this.id,
      {required PolylineTextStyle style,
      required String text,
      required this.points,
      bool visible = true})
      : _style = style,
        _text = text,
        _visible = visible;

  /// [PolylineText.style]을 변경합니다.
  Future<void> changeStyles(PolylineTextStyle style) async {
    _style = style;
    await _controller._changePolylineTextStyle(id, style);
  }

  /// [PolylineText]의 스타일과 내용을 변경합니다.
  Future<void> changeTextAndStyles(String text, PolylineTextStyle style) async {
    _style = style;
    _text = text;
    await _controller._changePolylineTextStyle(id, style, text);
  }

  /// [PolylineText.text]을 변경합니다.
  Future<void> changeText(String text) async {
    _text = text;
    await _controller._changePolylineTextStyle(id, _style, text);
  }

  /// [PolylineText]를 삭제합니다.
  Future<void> remove() async {
    await _controller.removePolylineText(this);
  }

  /// [PolylineText]를 지도에서 노출되지 않도록 합니다.
  Future<void> hide() async {
    await _controller._changePolylineTextVisible(id, false);
    _visible = false;
  }

  /// [PolylineText]를 지도에서 보이도록 합니다.
  Future<void> show() async {
    await _controller._changePolylineTextVisible(id, true);
    _visible = true;
  }
}
