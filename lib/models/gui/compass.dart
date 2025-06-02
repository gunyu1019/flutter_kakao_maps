part of '../../kakao_map_sdk.dart';

/// 지도에 표시된 나침판을 관리하는 객체입니다.
class Compass extends DefaultGUI {
  @override
  DefaultGUIType get type => DefaultGUIType.compass;

  final KakaoMapController _controller;

  Compass._({
    required KakaoMapController controller,
  }) : _controller = controller;

  /// 지도에 표시된 나침판을 숨깁니다.
  Future<void> hide() async {
    await _controller._defaultGUIvisible(type, false);
  }

  /// 지도에 표시된 나침판을 표시합니다.
  Future<void> show() async {
    await _controller._defaultGUIvisible(type, true);
  }

  /// 지도에 표시된 나침판의 위치를 조정합니다.
  Future<void> changePosition(MapGravity gravity, double x, double y) async {
    await _controller._defaultGUIposition(type, gravity, x, y);
  }
}
