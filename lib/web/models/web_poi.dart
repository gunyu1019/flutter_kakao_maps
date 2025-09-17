part of '../kakao_map_sdk_web.dart';

class WebPoi {
  final String id;
  final WebCustomOverlay overlay;

  int currentLevel;

  final Map<int, String> preEncodedImage = {};
  // final Map<String, ...> badge;
  // final List<...> shareTransformPoi;
  // final List<...> shareTransformShape;

  String? text;
  String styleId;

  WebPoi(this.id, this.overlay, {
    required this.currentLevel,
    required this.text,
    required this.styleId,
  });
}