part of '../../kakao_map_sdk.dart';

/// 카메라 이동의 애니메이션을 정의하는 객체입니다.
class CameraAnimation with KMessageable {
  /// 애니메이션 지속 시간을 설정합니다.
  final int duration;

  /// 일정 거리 이상을 이동할 때, 카메라의 높이를 조절할지 선택합니다.
  final bool autoElevation;

  /// 이동 중인 애니메이션 효과가 있을 때, 이어서 애니매이션 효과를 표현할지 선택합니다.
  final bool isConsecutive;

  const CameraAnimation(this.duration,
      {this.autoElevation = false, this.isConsecutive = false});

  @override
  Map<String, dynamic> toMessageable() {
    return {
      "duration": duration,
      "autoElevation": autoElevation,
      "isConsecutive": isConsecutive,
    };
  }

  factory CameraAnimation.fromMessageable(dynamic payload) =>
      CameraAnimation(payload["duration"],
          autoElevation: payload["autoElevation"] ?? false,
          isConsecutive: payload["isConsecutive"] ?? false);
}
