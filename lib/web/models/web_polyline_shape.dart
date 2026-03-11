part of '../kakao_map_sdk_web.dart';

class WebPolylineShape {
  final String id;

  final WebPolyline element;
  WebPolyline? strokeElement;

  WebPolylineOption option;
  WebPolylineOption? strokeOption;

  String styleId;
  PolylineStyle style;
  int currentLevel;

  WebPolylineShape(
    this.id,
    this.element,
    this.strokeElement, {
    required this.option,
    required this.strokeOption,
    required this.style,
  })  : styleId = style.id!,
        currentLevel = style.zoomLevel;
}
