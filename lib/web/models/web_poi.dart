part of '../kakao_map_sdk_web.dart';

class WebPoi {
  final String id;
  final WebCustomOverlay overlay;

  int currentLevel;

  Map<int, String> preEncodedImage = {};
  String? text;
  String styleId;

  WebPoi(this.id, this.overlay, {
    required this.currentLevel,
    required this.text,
    required this.styleId,
  });
}