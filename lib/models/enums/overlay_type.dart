part of '../../kakao_map_sdk.dart';

enum OverlayType {
  label(value: 1),
  lodLabel(value: 2),
  shape(value: 3),
  route(value: 4),
  dimScreen(value: 5);

  final int value;

  const OverlayType({required this.value});
}
