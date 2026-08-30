part of '../kakao_map_sdk_web.dart';

class WebDimHighlightShape {
  final String id;
  final int zOrder;
  final int insertionOrder;

  WebShapePoint point;
  PolygonStyle style;
  bool visible = true;

  WebPolygon? element;
  WebPolygonOption? option;
  final List<WebPolyline> strokeElements = [];
  final List<WebPolylineOption> strokeOptions = [];

  WebDimHighlightShape(
    this.point,
    this.style,
    this.id,
    this.zOrder,
    this.insertionOrder,
  );
}
