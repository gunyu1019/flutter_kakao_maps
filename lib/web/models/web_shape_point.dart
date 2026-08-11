part of '../kakao_map_sdk_web.dart';

class WebShapePoint {
  final List<LatLng> path;
  final List<List<LatLng>> holes = [];

  WebShapePoint([List<LatLng>? path]) : path = path ?? [];

  Iterable<List<LatLng>> get rings sync* {
    yield path;
    yield* holes;
  }

  /// Native DimScreen polygon strokes are closed even when the serialized
  /// ring does not repeat its first point. Kakao Web draws the stroke with a
  /// separate Polyline, so close each usable ring explicitly.
  Iterable<List<LatLng>> get strokeRings => rings
      .where((ring) => ring.length >= 2)
      .map((ring) => ring.first == ring.last ? ring : [...ring, ring.first]);

  JSArray<JSArray<WebLatLng>> toPolygonPath() {
    return rings
        .map((ring) => ring.map(WebLatLng.fromLatLng).toList().toJS)
        .toList()
        .toJS;
  }

  JSArray<WebLatLng> toPolylinePath() =>
      path.map(WebLatLng.fromLatLng).toList().toJS;

  factory WebShapePoint.fromMessageable(dynamic payload) =>
      switch (payload["type"]) {
        0 => WebShapePoint.fromMapPoint(payload),
        1 => WebShapePoint.fromDotPoint(payload),
        Object() || null => throw UnimplementedError(),
      };

  factory WebShapePoint.fromMapPoint(dynamic payload) {
    final path = <LatLng>[];
    for (final rawPoint in payload["points"] as Iterable) {
      path.add(LatLng.fromMessageable(rawPoint));
    }
    final point = WebShapePoint(path);

    if (payload.containsKey("holes")) {
      for (final rawHole in payload["holes"] as Iterable) {
        final hole = <LatLng>[];
        for (final rawPoint in rawHole as Iterable) {
          hole.add(LatLng.fromMessageable(rawPoint));
        }
        point.holes.add(hole);
      }
    }
    return point;
  }

  static List<LatLng> _getPointFromDotPoint(
    dynamic payload, [
    LatLng? basePoint,
  ]) {
    List<LatLng> absolutePoint = <LatLng>[];
    final basePoint0 =
        basePoint ?? LatLng.fromMessageable(payload["basePoint"]);
    final dotType = PointShapeType.values.firstWhere(
      (e) => e.value == payload["dotType"],
    );
    final clockwise = payload["clockwise"];

    switch (dotType) {
      case PointShapeType.circle:
        final radius = payload["radius"];
        Iterable.generate(360)
            .map<LatLng>((deg) => basePoint0.offset(radius, deg.toDouble()))
            .forEach(absolutePoint.add);
      case PointShapeType.rectangle:
        final width = payload["width"];
        final height = payload["height"];
        absolutePoint.addAll([
          basePoint0.offset(-width * .5, 90).offset(height * .5, 0),
          basePoint0.offset(height * .5, 0).offset(width * .5, 90),
          basePoint0.offset(width * .5, 90).offset(-height * .5, 0),
          basePoint0.offset(-height * .5, 0).offset(-width * .5, 90),
          basePoint0.offset(-width * .5, 90).offset(height * .5, 0),
        ]);
      case PointShapeType.points:
      case PointShapeType.none:
        throw UnimplementedError();
    }

    if (clockwise) absolutePoint = absolutePoint.reversed.toList();
    return absolutePoint;
  }

  factory WebShapePoint.fromDotPoint(dynamic payload) {
    final point = WebShapePoint(_getPointFromDotPoint(payload));
    if (payload.containsKey("holes") && payload["holes"].length > 0) {
      payload["holes"].map(_getPointFromDotPoint).forEach(point.holes.add);
    }
    return point;
  }
}
