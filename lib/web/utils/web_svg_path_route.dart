part of '../kakao_map_sdk_web.dart';

/// LatLng 목록을 투영해 SVG 경로와 CustomOverlay 배치 정보를 계산한다.
/// pan 시 좌표 차이가 불변이므로 zoom_changed 이벤트에서만 재계산하면 된다.
WebSvgPathRouteGeometry svgPathRoute(
  List<LatLng> points,
  WebMapController controller, {
  LatLng? anchor,
}) {
  if (points.isEmpty) {
    throw ArgumentError.value(points, 'points', 'PolylineText points must not be empty');
  }

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
    var totalLength = 0.0;
    final segmentLengths = <double>[];
    for (var index = 1; index < projected.length; index++) {
      final dx = projected[index].x - projected[index - 1].x;
      final dy = projected[index].y - projected[index - 1].y;
      final length = math.sqrt(dx * dx + dy * dy);
      segmentLengths.add(length);
      totalLength += length;
    }

    var remainingLength = totalLength / 2;
    var anchorPoint = projected.first;
    for (var index = 0; index < segmentLengths.length; index++) {
      final length = segmentLengths[index];
      if (length == 0 || remainingLength > length) {
        remainingLength -= length;
        continue;
      }
      final start = projected[index];
      final end = projected[index + 1];
      final ratio = remainingLength / length;
      anchorPoint = WebPoint(
        start.x + (end.x - start.x) * ratio,
        start.y + (end.y - start.y) * ratio,
      );
      break;
    }

    anchorPosition =
        projection.coordsFromContainerPoint(anchorPoint).toLatLng();
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
