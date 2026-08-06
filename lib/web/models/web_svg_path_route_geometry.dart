part of '../kakao_map_sdk_web.dart';

/// SVG 경로와 CustomOverlay 배치에 필요한 투영 결과입니다.
class WebSvgPathRouteGeometry {
  final String pathData;
  final LatLng anchor;
  final double minX;
  final double minY;
  final double width;
  final double height;

  const WebSvgPathRouteGeometry({
    required this.pathData,
    required this.anchor,
    required this.minX,
    required this.minY,
    required this.width,
    required this.height,
  });
}
