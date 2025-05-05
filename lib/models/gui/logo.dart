part of '../../kakao_map_sdk.dart';

/// 지도에 표시된 로고을 관리하는 객체입니다.
class Logo extends DefaultGUI {
  @override
  DefaultGUIType get type => DefaultGUIType.logo;

  final KakaoMapController _controller;

  Logo._({
    required KakaoMapController controller,
  }) : _controller = controller;

  /// 지도에 표시된 나침판의 위치를 조정합니다.
  Future<void> changePosition(MapGravity gravity, double x, double y) async {
    await _controller._defaultGUIposition(type, gravity, x, y);
  }
}
