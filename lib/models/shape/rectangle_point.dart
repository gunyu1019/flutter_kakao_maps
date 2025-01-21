part of '../../flutter_kakao_map.dart';


class RectanglePoint extends _BaseDotPoint {
  final double width;
  final double height;
  final bool clockwise;

  RectanglePoint(
    super.basePoint,
    this.width,
    this.height, {
      this.clockwise = false
  });

  @override
  Map<String, dynamic> toMessageable() {
    final payload = <String, dynamic>{
      "type": type,
      "width": width,
      "height": height,
      "clockwise": clockwise,
    };
    payload.addAll(super.toMessageable());
    return payload;
  }

  @override
  int get type => 1;
}