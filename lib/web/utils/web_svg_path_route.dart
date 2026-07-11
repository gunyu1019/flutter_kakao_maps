part of '../kakao_map_sdk_web.dart';

/// LatLng 목록을 투영해 SVG 경로와 CustomOverlay 배치 정보를 계산한다.
/// pan 시 좌표 차이가 불변이므로 zoom_changed 이벤트에서만 재계산하면 된다.
WebSvgPathRouteGeometry svgPathRoute(
  List<LatLng> points,
  WebMapController controller, {
  LatLng? anchor,
}) {
  final projection = controller.getProjection();
  final projected = points
      .map(
        (point) => projection.containerPointFromCoords(
          WebLatLng.fromLatLng(point),
        ),
      )
      .toList();

  final LatLng anchorPosition;
  if (anchor != null) {
    anchorPosition = anchor;
  } else {
    var absoluteMinX = projected.first.x;
    var absoluteMaxX = absoluteMinX;
    var absoluteMinY = projected.first.y;
    var absoluteMaxY = absoluteMinY;
    for (final point in projected.skip(1)) {
      if (point.x < absoluteMinX) absoluteMinX = point.x;
      if (point.x > absoluteMaxX) absoluteMaxX = point.x;
      if (point.y < absoluteMinY) absoluteMinY = point.y;
      if (point.y > absoluteMaxY) absoluteMaxY = point.y;
    }
    anchorPosition = projection
        .coordsFromContainerPoint(
          WebPoint(
            (absoluteMinX + absoluteMaxX) / 2,
            (absoluteMinY + absoluteMaxY) / 2,
          ),
        )
        .toLatLng();
  }
  final anchorPoint = projection.containerPointFromCoords(
    WebLatLng.fromLatLng(anchorPosition),
  );

  var minX = projected.first.x - anchorPoint.x;
  var maxX = minX;
  var minY = projected.first.y - anchorPoint.y;
  var maxY = minY;
  final pathBuffer = StringBuffer();
  for (int i = 0; i < projected.length; i++) {
    final point = projected[i];
    final x = point.x - anchorPoint.x;
    final y = point.y - anchorPoint.y;
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
    final xText = x.toStringAsFixed(2);
    final yText = y.toStringAsFixed(2);
    pathBuffer.write(i == 0 ? "M $xText $yText" : " L $xText $yText");
  }

  final boxMinX = maxX == minX ? minX - 0.5 : minX;
  final boxMinY = maxY == minY ? minY - 0.5 : minY;
  return WebSvgPathRouteGeometry(
    pathData: pathBuffer.toString(),
    anchor: anchorPosition,
    minX: boxMinX,
    minY: boxMinY,
    width: maxX == minX ? 1.0 : maxX - minX,
    height: maxY == minY ? 1.0 : maxY - minY,
  );
}
