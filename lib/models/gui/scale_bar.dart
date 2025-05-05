part of '../../kakao_map_sdk.dart';

/// 지도에 표시된 축적바을 관리하는 객체입니다.
class ScaleBar extends DefaultGUI {
  @override
  DefaultGUIType get type => DefaultGUIType.scale;

  final KakaoMapController _controller;

  ScaleBar._({
    required KakaoMapController controller,
  }) : _controller = controller;

  /// 지도에 표시된 축적바를 숨깁니다.
  Future<void> hide() async {
    await _controller._defaultGUIvisible(type, false);
  }

  /// 지도에 표시된 축적바를 표시합니다.
  Future<void> show() async {
    await _controller._defaultGUIvisible(type, true);
  }

  /// 지도에 표시된 축적바의 위치를 조정합니다.
  Future<void> changePosition(MapGravity gravity, double x, double y) async {
    await _controller._defaultGUIposition(type, gravity, x, y);
  }

  /// 지도에 표시된 축적바가 나타나고 사라지는 시간을 설정합니다.
  /// [retention] 값은 축적바가 나타나고 사라자기 전까지의 사긴입니다.
  Future<void> setAnimationTime(int fadeIn, int fadeOut, int retention) async {
    await _controller._scaleAnimationTime(fadeIn, fadeOut, retention);
  }

  /// 일정 시간이 지나면 지도에 표시된 축적바가 사라지도록 설정합니다.
  Future<void> setAutohide(bool autohide) async {
    await _controller._scaleAutohide(autohide);
  }
}
