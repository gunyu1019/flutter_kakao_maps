part of '../kakao_map_sdk_web.dart';

class WebPoiBadge {
  final String id;

  final double offsetX;

  final double offsetY;

  final int zOrder;

  final KImage image;
  late final String preEncodedImage;

  bool visible;

  WebPoiBadge(
    this.id,
    this.offsetX,
    this.offsetY,
    this.image, [
    this.visible = true,
    this.zOrder = 0,
  ]);

  Future<void> encodeImage() async =>
      preEncodedImage = encodeImageToBase64(await image.readBytes());
}
