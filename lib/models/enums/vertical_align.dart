part of '../../kakao_map_sdk.dart';

enum VerticalAlign {
  top(4, 0),
  center(64, 1),
  bottom(8, 2);

  final int aosValue;
  final int iosValue;

  const VerticalAlign(this.aosValue, this.iosValue);
}
