part of '../../kakao_map_sdk.dart';

enum HorizontalAlign {
  left(1, 0),
  center(32, 1),
  right(2, 2);

  final int aosValue;
  final int iosValue;

  const HorizontalAlign(this.aosValue, this.iosValue);
}
