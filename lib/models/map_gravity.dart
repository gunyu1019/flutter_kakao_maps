part of '../kakao_map_sdk.dart';

/// 지도에 [Compass], [ScaleBar], [Logo]의 위치를 선택할 때, 기준점을 정의하는 객체입니다.
class MapGravity {
  final HorizontalAlign horizontalAlign;
  final VerticalAlign verticalAlign;

  const MapGravity(this.horizontalAlign, this.verticalAlign);

  /// 지도의 중앙을 기준으로 합니다.
  const MapGravity.center()
      : horizontalAlign = HorizontalAlign.center,
        verticalAlign = VerticalAlign.center;

  int get value {
    if (kIsWeb || Platform.isIOS) {
      return horizontalAlign.iosValue * 3 + verticalAlign.iosValue;
    } else if (Platform.isAndroid) {
      if (horizontalAlign == HorizontalAlign.center &&
          verticalAlign == VerticalAlign.center) {
        return 16;
      }
      return horizontalAlign.aosValue | verticalAlign.aosValue;
    }
    return -1;
  }

  factory MapGravity.fromValue(int value) => MapGravity(
      HorizontalAlign.values
          .firstWhere((e) => e.iosValue == (value / 3).toInt()),
      VerticalAlign.values.firstWhere((e) => e.iosValue == value % 3));
}
