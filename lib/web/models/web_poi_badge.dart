part of '../kakao_map_sdk_web.dart';

class WebPoiBadge {
  final String id;

  final double offsetX;

  final double offsetY;

  final int zOrder;

  final KImage image;

  bool visible;

  WebPoiBadge(
      this.id,
      this.offsetX,
      this.offsetY,
      this.image,
      [this.visible = true, this.zOrder = 0]
  );
}
