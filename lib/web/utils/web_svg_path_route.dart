part of '../kakao_map_sdk_web.dart';

/// LatLng 목록을 첫 번째 점 기준 오프셋 픽셀 좌표로 변환해 SVG path "d" 문자열을 반환한다.
/// pan 시 오프셋 차이가 불변이므로 zoom_changed 이벤트에서만 재계산하면 된다.
String svgPathRoute(List<LatLng> points, WebMapController controller) {
  final projection = controller.getProjection();
  final anchorPoint =
      projection.containerPointFromCoords(WebLatLng.fromLatLng(points[0]));
  final pathBuffer = StringBuffer("M 0 0");
  for (int i = 1; i < points.length; i++) {
    final point =
        projection.containerPointFromCoords(WebLatLng.fromLatLng(points[i]));
    pathBuffer.write(
      " L ${(point.x - anchorPoint.x).toStringAsFixed(2)} ${(point.y - anchorPoint.y).toStringAsFixed(2)}",
    );
  }
  return pathBuffer.toString();
}
