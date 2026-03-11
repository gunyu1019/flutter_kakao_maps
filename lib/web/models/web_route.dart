part of '../kakao_map_sdk_web.dart';

class WebRoute {
  final String id;
  final List<WebRouteElement> element;

  String styleId;
  int zOrder;

  final List<int> styleIndex;
  final List<int> currentLevel;

  WebRoute(
    this.id,
    this.element, {
    required this.currentLevel,
    required this.styleIndex,
    required this.styleId,
    this.zOrder = 0,
  });
}
