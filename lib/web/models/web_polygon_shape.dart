part of '../kakao_map_sdk_web.dart';

class WebPolygonShape {
  final String id;
  final WebPolygon element;

  WebPolygonOption option;

  String styleId;
  PolygonStyle style;
  int currentLevel;

  WebPolygonShape(
    this.id,
    this.element, {
    required this.option,
    required this.style,
  })  : styleId = style.id!,
        currentLevel = style.zoomLevel;
}
