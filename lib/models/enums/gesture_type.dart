part of '../../kakao_map_sdk.dart';

/// 지도에서 제스처 유형을 나타냅니다.
enum GestureType {
  /// 한 손가락으로 한 번 탭하여 화면을 확대하는 제스처 유형입니다.
  oneFingerDoubleTap(value: 1),

  /// 두 손가락으로 한 번 탭하여 화면을 축소하는 제스처 유형입니다.
  twoFingerSingleTap(value: 2),

  /// 한 손가락으로 지도를 상하좌우로 이동하는 제스처 유형입니다.
  pan(value: 5),

  /// 회전 제스쳐 입니다.
  /// 두 손가락을 이용하여 화면을 회전하는 제스처 유형입니다.
  rotate(value: 6),

  /// 확대 / 축소 제스처입니다.
  /// 두 손가락을 이용하여 화면을 확대(밀어내기) 또는 축소(당기기) 제스처 유형입니다.
  zoom(value: 7),

  /// 기울기 제스처입니다.
  /// 두 손가락을 이용하여 화면을 밀어내는 제스처 유형입니다.
  tilt(value: 8),

  /// 길게 누르고, 드래그하는 제스처입니다.
  longTapAndDrag(value: 9),

  /// 회전을 하고 확대/축소를 하는 제스처입니다.
  rotateZoom(value: 10),

  /// 한 손가락으로 두 번 탭하고 위아래로 스크롤해서 축소/확대 하는 제스처입니다.
  oneFingerZoom(value: 11),

  /// 정의되지 않은 제스처 유형입니다.
  /// [KakaoMapController.moveCamera] 등의 자동으로 카메라가 이동한 경우
  /// [GestureType.unknown]이 적용됩니다.
  unknown(value: 17);

  final int value;

  const GestureType({required this.value});

  static GestureType fromValue(int value) => GestureType.values
      .firstWhere((el) => value == el.value, orElse: () => GestureType.unknown);

  // # Github Issue (#20)
  // iOS 환경에서 카메라 값은 GestureType이 아닌, MoveBy라는 특수한 열거형 클래스 형태로 반환됩니다.
  // MoveBy와 GestureType의 열거형 타입의 의도는 큰 차이가 없으나, 실제 내부 값의 차이가 존재하기
  // 의도와 다른 값을 반환받을 수 도 있습니다.
  static GestureType _fromMoveByValue(int value) => switch (value) {
        0 => GestureType.oneFingerDoubleTap,
        1 => GestureType.twoFingerSingleTap,
        2 => GestureType.pan,
        3 => GestureType.rotate,
        4 => GestureType.zoom,
        5 => GestureType.tilt,
        6 => GestureType.longTapAndDrag,
        7 => GestureType.rotateZoom,
        8 => GestureType.oneFingerZoom,
        int() => GestureType.unknown
      };
}
