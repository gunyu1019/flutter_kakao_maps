part of '../kakao_map_sdk_web.dart';


class WebDimHighlightShape {
  final String id;

  WebShapePoint point;
  PolygonStyle style;
  bool visible = true;

  WebPolygon? element;
  WebPolygonOption? option;

  WebDimHighlightShape(this.point, this.style, this.id);
}